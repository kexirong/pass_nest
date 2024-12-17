import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pass_nest/models/webdav_config.dart';

import '../../models/account/account_group.dart';
import '../../models/account/account.dart';
import '../../models/account/change_record.dart';

import '../accounts_service.dart';
import '../db/data_provider.dart';
import '../config_service.dart';
import '../groups_service.dart';
import 'webdav.dart';

const lockFile = '.lock';

class SyncWebdavService extends GetxService {
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

  WebdavClient? _client;

  Future<WebdavClient?> get client async {
    if (_client != null && !(_client!.isClose)) {
      return _client;
    }
    return await _getClient();
  }

  Future<WebdavClient?> _getClient() async {
    var conf = await _configService.getWebdavConfig();
    if (conf == null) return null;
    _client = WebdavClient(conf.url, conf.user, conf.password, path: conf.path);
    return _client;
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
    timer = Timer.periodic(const Duration(seconds: 30), (timer) => callbackSync(timer));
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
    print('callbackSync&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
    if (await sync()) {
      print('sync completed');
      lastTime = DateTime.now();
    }
  }

  Future<bool> sync() async {
    var method = await _configService.getSyncMethod();
    if (method != SyncMethod.webdav) return false;
    var client_ = await client;
    if (client_ == null) return false;
    try {
      if (!isInit || isRunning) {
        if (kDebugMode) {
          print('sync skip');
        }
        return false;
      }

      if (await hasLock(client_)) return false;
      isRunning = true;

      await lock(client_);

      var records = await _dataProvider.getChangeRecords();
      var lzRecords = zipRecords(records);
      Map<String, ChangeRecord> cRecords;
      try {
        var ret = await client_.download('change_records_mate');
        cRecords = _toRecords(json.decode(ret));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) {
          rethrow;
        }
        cRecords = {};
      }

      var downWait = diffRecords(lzRecords, cRecords);
      print(downWait);
      var upWait = diffRecords(cRecords, lzRecords);
      print(upWait);
      for (var down in downWait) {
        var itemStr = await client_.download("${down.itemType.name}_${down.id}");
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
            //need fix
            dataStr = _groupsService.getGroupByID(up.id).toString();

          case ItemType.account:
            //need fix
            dataStr = _accountsService.getAccountByID(up.id).toString();
        }
        await client_.upload("${up.itemType.name}_${up.id}", dataStr);
      }
      var uRecords = lzRecords.values.toList();
      uRecords.addAll(upWait);
      await client_.upload("change_records_mate", jsonEncode(uRecords));

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    } finally {
      await unlock(client_);
      isRunning = false;
    }
  }

  Future<bool> hasLock(WebdavClient client) async {
    try {
      var ret = await client.download(lockFile);
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

  Future<void> lock(WebdavClient client) async {
    var deviceID = _configService.deviceID;

    var lockData = <String, dynamic>{
      'device_id': deviceID,
      'expired': DateTime.now().add(_duration).millisecondsSinceEpoch,
    };
    await client.upload(lockFile, json.encode(lockData));
  }

  Future<void> unlock(WebdavClient client) async {
    await client.remove(lockFile);
  }

  void clientClose() {
    _client?.close();
  }
}

Map<String, ChangeRecord> _toRecords(List<dynamic> jsonInstance) {
  List<ChangeRecord> records = [];
  for (var i in jsonInstance) {
    var rm = ChangeRecord.fromJson(i);
    records.add(rm);
  }
  return zipRecords(records);
}
