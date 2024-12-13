import 'dart:convert';

import 'package:sembast/sembast.dart';

import '../../../models/webdav_config.dart';
import '../../../models/secret_config.dart';
import '../../../utils/util.dart';

class SettingStore {
  static const storeName = 'nest_setting';
  final _webdavField = 'webdav';
  final _deviceIDField = 'device_id';
  final _secretsField = 'secrets';
  final _syncMethodField = 'sync_method';

  final StoreRef<String, String> _store = StoreRef<String, String>(storeName);

  SettingStore();

  Future<String> getDeviceID(DatabaseClient dbc) async {
    var record = _store.record(_deviceIDField);
    var devID = await record.get(dbc);
    if (devID == null) {
      devID = uuid();
      await record.add(dbc, devID);
    }
    return devID;
  }

  //isMaster即主密钥
  //用于所有账号数据加密/重新加密
  //非master为attSecrets
  //仅用于数据解密
  Future<List<SecretConfig>> getSecrets(DatabaseClient dbc) async {
    var ret = <SecretConfig>[];
    var secrets = await _store.record(_secretsField).get(dbc);

    if (secrets != null) {
      var jsonList = jsonDecode(secrets);
      for (var i in jsonList) {
        ret.add(SecretConfig.fromJson(i));
      }
    }
    return ret;
  }

  Future<String> setSecrets(DatabaseClient dbc, List<SecretConfig> secrets) async {
    return await _store.record(_secretsField).put(dbc, jsonEncode(secrets));
  }

  Future<WebdavConfig?> getWebdavConfig(DatabaseClient dbc) async {
    var record = _store.record(_webdavField);
    var webdavStr = await record.get(dbc);

    if (webdavStr == null) return null;
    var jsonMap = jsonDecode(webdavStr);
    return WebdavConfig.fromJson(jsonMap);
  }

  Future<String> setWebdavConfig(DatabaseClient dbc, WebdavConfig wc) async {
    var wcStr = jsonEncode(wc);
    return await _store.record(_webdavField).put(dbc, wcStr);
  }

  Future<String?> getSyncMethod(DatabaseClient dbc) async {
    return await _store.record(_syncMethodField).get(dbc);
  }

  Future<String> setSyncMethod(DatabaseClient dbc, String method) async {
    return await _store.record(_syncMethodField).put(dbc, method);
  }

  Future<List<RecordSnapshot<String, String>>> getAll(DatabaseClient dbc) async {
    return await _store.find(dbc);
  }

  Future<String?> get(DatabaseClient dbc, String key) async {
    return await _store.record(key).get(dbc);
  }

  Future<String?> add(DatabaseClient dbc, String key, String value) async {
    return await _store.record(key).add(dbc, value);
  }
}
