import 'dart:async';
import 'dart:convert';

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

// 使用启动同步，编辑同步，不采用定时同步
class SyncWebdavService extends GetxService {
  final _dataProvider = Get.find<DataProviderService>();
  final _configService = Get.find<ConfigService>();
  final _accountsService = Get.find<AccountsService>();
  final _groupsService = Get.find<GroupsService>();

  bool _isSyncing = false;
  bool _needSync = false;
  final _duration = const Duration(seconds: 30);
  final _syncController = StreamController<void>();

  @override
  void onInit() {
    _syncController.stream.listen(
      (_) {
        if (_isSyncing) {
          _needSync = true;
          return;
        }
        _sync().then((value) {
          if (value != null && !value) {
            var duration = _needSync ? Duration.zero : const Duration(seconds: 5);
            Timer(duration, () {
              print('timer  _syncController.sink.add(null);');
              _syncController.sink.add(null);
            });
          }
        });
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error: $error');
        }
      },
    );

    super.onInit();
  }

  @override
  void onClose() {
    _syncController.close();
    // _doSyncController.close();
    super.onClose();
  }

  WebdavClient? _webdavClient;

  Future<WebdavClient?> get webdavClient async {
    if (_webdavClient != null && !(_webdavClient!.isClose)) {
      return _webdavClient;
    }
    return await _getClient();
  }

  Future<WebdavClient?> _getClient() async {
    var conf = await _configService.getWebdavConfig();
    if (conf == null) return null;
    return _webdavClient = WebdavClient(conf.url, conf.user, conf.password, path: conf.path);
  }

  void notifySync() {
    _syncController.sink.add(null);
  }

  Future<bool?> _sync() async {
    print('start sync========================================================');
    var method = await _configService.getSyncMethod();
    if (method != SyncMethod.webdav) return null;
    var client = await webdavClient;
    if (client == null) return null;
    try {
      _isSyncing = true;

      if (await _hasLock(client)) return false;

      await _lock(client);

      var records = await _dataProvider.getChangeRecords();
      var lzRecords = zipRecords(records);

      var ret = await client.read('change_records_mate');
      Map<String, ChangeRecord> cRecords = ret == null ? {} : _toRecords(json.decode(ret));

      final syncEvents = diffRecords(lzRecords, cRecords);
      if (kDebugMode) {
        print('syncEvents:$syncEvents');
      }
      for (var event in syncEvents) {
        switch (event.action) {
          case SyncAction.upload:
            String dataStr;
            switch (event.itemType) {
              case ItemType.group:
                dataStr = _groupsService.getGroupByID(event.itemID).toString();

              case ItemType.account:
                dataStr = _accountsService.getAccountByID(event.itemID).toString();
            }
            await client.write("${event.itemType.name}_${event.itemID}", dataStr);
          case SyncAction.add:
          case SyncAction.update:
            var itemStr = await client.read("${event.itemType.name}_${event.itemID}");
            if (itemStr == null) {
              continue;
            }
            var item = jsonDecode(itemStr);
            switch (event.itemType) {
              case ItemType.group:
                var ag = AccountGroup.fromJson(item);
                await (event.action == SyncAction.add
                    ? _groupsService.addGroup(ag)
                    : _groupsService.updateGroup(ag));
              case ItemType.account:
                BaseAccount acct;
                if (item.containsKey('cipher')) {
                  acct = EncryptAccount.fromJson(item);
                } else {
                  acct = PlainAccount.fromJson(item);
                }
                await (event.action == SyncAction.add
                    ? _accountsService.addAccount(acct)
                    : _accountsService.updateAccount(acct));
            }
          case SyncAction.delete:
            switch (event.itemType) {
              case ItemType.group:
                var group = _groupsService.getGroupByID(event.itemID);
                if (group != null) {
                  await _groupsService.deleteGroup(group);
                }
              case ItemType.account:
                var acct = _accountsService.getAccountByID(event.itemID);
                if (acct != null) {
                  await _accountsService.deleteAccount(acct);
                }
            }
          case SyncAction.remoteDelete:
            await client.delete("${event.itemType.name}_${event.itemID}");
        }
      }
      var lRecords = await _dataProvider.getChangeRecords();

      await client.write("change_records_mate", jsonEncode(zipRecords(lRecords).values.toList()));

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      print('sync catch~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      return false;
    } finally {
      try {
        await _unlock(client);
      } finally {
        _isSyncing = false;
        if (_needSync) {
          _syncController.sink.add(null);
          _needSync = false;
        }
      }
    }
  }

  Future<bool> _hasLock(WebdavClient client) async {
    var ret = await client.read(lockFile);
    if (ret == null) return false;
    var jRet = json.decode(ret);
    int expired = jRet['expired'];
    if (DateTime.now().millisecondsSinceEpoch > expired) {
      return false;
    }

    return true;
  }

  Future<void> _lock(WebdavClient client) async {
    var deviceID = _configService.deviceID;

    var lockData = <String, dynamic>{
      'device_id': deviceID,
      'expired': DateTime.now().add(_duration).millisecondsSinceEpoch,
    };
    await client.write(lockFile, json.encode(lockData));
  }

  Future<void> _unlock(WebdavClient client) async {
    await client.delete(lockFile);
  }

  void clientClose() {
    _webdavClient?.close();
  }
}

enum SyncAction { add, update, delete, upload, remoteDelete }

class SyncEvent {
  String itemID;
  ItemType itemType;
  SyncAction action;

  SyncEvent(this.itemID, this.itemType, this.action);

  @override
  String toString() {
    return "{'item_id':$itemID,'item_type':$itemType,'action':${action.name}";
  }
}

Map<ID, ChangeRecord> zipRecords(List<ChangeRecord> records) {
  Map<ID, ChangeRecord> recs = {};
  for (var item in records) {
    var value = recs[item.id];
    if (value == null) {
      recs[item.id] = item;
      continue;
    }
    if (value.recordType.index >= item.recordType.index && value.timestamp >= item.timestamp) {
      continue;
    }
    recs[item.id] = item;
  }
  return recs;
}

Map<String, ChangeRecord> _toRecords(List<dynamic> jsonInstance) {
  List<ChangeRecord> records = [];
  for (var i in jsonInstance) {
    var rm = ChangeRecord.fromJson(i);
    records.add(rm);
  }
  return zipRecords(records);
}

List<SyncEvent> diffRecords(
    Map<ID, ChangeRecord> localRecords, Map<ID, ChangeRecord> remoteRecords) {
  List<SyncEvent> ses = [];

  remoteRecords.forEach((key, rItem) {
    var lItem = localRecords[key];
    if (lItem == null) {
      if (rItem.recordType != RecordType.delete) {
        ses.add(SyncEvent(key, rItem.itemType, SyncAction.add));
      }
      return;
    }
    if (rItem.recordType.index > lItem.recordType.index || rItem.timestamp > lItem.timestamp) {
      SyncAction action;
      switch (lItem.recordType) {
        case RecordType.delete:
          action = SyncAction.delete;
        case RecordType.create:
          action = SyncAction.add;
        case RecordType.update:
          action = SyncAction.update;
      }
      ses.add(SyncEvent(
          key, rItem.itemType, lItem.recordType == RecordType.delete ? SyncAction.delete : action));
    }
  });
  localRecords.forEach((key, lItem) {
    var rItem = remoteRecords[key];
    if (rItem == null) {
      if (lItem.recordType != RecordType.delete) {
        ses.add(SyncEvent(key, lItem.itemType, SyncAction.upload));
      }
      return;
    }
    if (lItem.recordType.index > rItem.recordType.index || lItem.timestamp > rItem.timestamp) {
      ses.add(SyncEvent(key, lItem.itemType,
          rItem.recordType == RecordType.delete ? SyncAction.remoteDelete : SyncAction.upload));
    }
  });

  return ses;
}
