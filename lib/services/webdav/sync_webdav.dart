import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../models/account/account_group.dart';
import '../../models/account/account.dart';
import '../../models/account/change_record.dart';

import '../accounts_service.dart';
import '../db/data_provider.dart';
import '../config_service.dart';
import '../groups_service.dart';
import 'webdav.dart';

const lockFile = '.lock';

class SyncWebdav extends GetxService {
  final _dataProvider = Get.find<DataProviderService>();
  final _configService = Get.find<ConfigService>();
  final _accountsService = Get.find<AccountsService>();
  final _groupsService = Get.find<GroupsService>();
  bool isInit = false;
  bool isRunning = false;
  Duration _duration = const Duration(seconds: 30);
  late DateTime lastTime;

  Timer? timer;

  DateTime get nextTime {
    return lastTime.add(_duration);
  }

  WebdavClient? get _client {
    var conf = _configService.webdavConfig;
    if (conf == null) return null;
    return WebdavClient(conf.url, conf.user, conf.password, path: conf.path, debug: false);
  }

  void start({Duration? duration}) {
    isInit = false;
    if (duration != null) {
      _duration = duration;
    }
    isInit = true;
    if (timer == null) {
      lastTime = DateTime.now().subtract(_duration);
      loop();
    }
  }

  void loop() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) => callbackSync(timer));
  }

  void stop() {
    for (var i = 0; i < 3; i++) {
      if (!isRunning) {
        timer?.cancel();
        return;
      }
      Timer(const Duration(seconds: 1), () {});
    }
  }

  void callbackSync(Timer t) async {
    if (DateTime.now().isBefore(nextTime)) {
      return;
    }
    if (await sync()) {
      lastTime = DateTime.now();
    }
  }

  Future<bool> sync() async {
    try {
      if (!isInit || isRunning) {
        if (kDebugMode) {
          print('sync skip');
        }
        return false;
      }
      if (_client == null) return false;

      if (await hasLock()) return false;
      isRunning = true;

      await lock();

      var records = await _dataProvider.getChangeRecords();
      var lzRecords = zipRecords(records);
      var ret = await _client!.download('change_records_mate');
      var cRecords = _toRecords(json.decode(ret));

      var downWait = diffRecords(lzRecords, cRecords);
      var upWait = diffRecords(cRecords, lzRecords);
      for (var down in downWait) {
        var itemStr = await _client!.download("${down.itemType.name}_${down.id}");
        var item = jsonDecode(itemStr);
        switch (down.itemType) {
          case ItemType.group:
            var ag = AccountGroup.fromJson(item);
            await _groupsService.addGroup(ag);
          case ItemType.account:
            BaseAccount acct;
            if (item.containsKey('cipher')) {
              acct = EncryptAccount.fromJson(item);
            } else {
              acct = PlainAccount.fromJson(item);
            }
            await _accountsService.addAccount(acct);
        }
      }
      for (var up in upWait) {
        String dataStr;
        switch (up.itemType) {
          case ItemType.group:
            dataStr = _groupsService.getGroupByID(up.id).toString();

          case ItemType.account:
            dataStr = _accountsService.getAccountByID(up.id).toString();
        }
        await _client!.upload("${up.itemType.name}_${up.id}", dataStr);
      }
      var uRecords = lzRecords.values.toList();
      uRecords.addAll(upWait);
      await _client!.upload("change_records_mate", jsonEncode(uRecords));

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    } finally {
      await unlock();
      isRunning = false;
    }
  }

  Future<bool> hasLock() async {
    try {
      var ret = await _client!.download(lockFile);
      var jRet = json.decode(ret);
      int expired = jRet['expired'];
      if (DateTime.now().millisecondsSinceEpoch > expired) {
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
    }
    return true;
  }

  Future<void> lock() async {
    var deviceID = _configService.deviceID;

    var lockData = <String, dynamic>{
      'device_id': deviceID,
      'expired': DateTime.now().add(_duration).millisecondsSinceEpoch,
    };
    await _client!.upload(lockFile, json.encode(lockData));
  }

  Future<void> unlock() async {
    await _client!.remove(lockFile);
  }
}

// var syncWebdav = SyncWebdav();

Map<String, ChangeRecord> _toRecords(List<dynamic> jsonInstance) {
  List<ChangeRecord> records = [];
  for (var i in jsonInstance) {
    var rm = ChangeRecord.fromJson(i);
    records.add(rm);
  }
  return zipRecords(records);
}
