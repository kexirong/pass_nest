import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';

import '../models/webdav_config.dart';
import '../models/secret_config.dart';
import 'db/data_provider.dart';

class ConfigService extends GetxService {
  final _dataProvider = Get.find<DataProviderService>();

  // final _secretsConfig = <SecretConfig>[];
  final _secretsCache = <String, SecretConfig>{};
  late final String _deviceID;

  WebdavConfig? _webdavConfig;

  String get deviceID => _deviceID;

  WebdavConfig? get webdavConfig => _webdavConfig;

  List<SecretConfig> get secretsConfig => _secretsCache.values.toList();

  Future<void> init() async {
    await loadDeviceID();
    await loadWebdavConfig();
    await loadSecretsConfig();
  }

  Future<void> loadWebdavConfig() async {
    _webdavConfig = await _dataProvider.getWebdavConfig();
  }

  Future<void> loadDeviceID() async {
    _deviceID = await _dataProvider.getDeviceID();
  }

  Future<void> loadSecretsConfig() async {
    var secrets = await _dataProvider.getSecrets();
    // _secretsConfig.addAll(secrets);
    for (var s in secrets) {
      var mKey_ = md5.convert(utf8.encode(s.secret)).toString();
      _secretsCache[mKey_] = s;
    }
  }

  String? get mainSecret => _getMainSecret()?.secret;

  bool isMainSecret(String mKey) {
    var secret = _secretsCache[mKey];
    return secret == null ? false : secret.isMain;
  }

  SecretConfig? _getMainSecret() {
    for (var s in secretsConfig) {
      if (s.isMain) {
        return s;
      }
    }
    return null;
  }

  String? getSecret(String mKey) {
    return _secretsCache[mKey]?.secret;
  }

  Future<void> setMainSecret(String secret) async {
    var mSecret = _getMainSecret();

    if (mSecret != null) {
      mSecret.isMain = false;
    }
    var newSecret = SecretConfig(secret, isMain: true);
    var mKey = md5.convert(utf8.encode(secret)).toString();
    _secretsCache[mKey] = newSecret;
    await _dataProvider.setSecrets(secretsConfig);
  }

  Future<void> addSecret(String secret) async {
    var newSecret = SecretConfig(secret);
    var mKey = md5.convert(utf8.encode(secret)).toString();
    _secretsCache[mKey] = newSecret;

    await _dataProvider.setSecrets(secretsConfig);
  }

  Future<void> deleteSecret(String secret) async {
    var mKey = md5.convert(utf8.encode(secret)).toString();
    _secretsCache.remove(mKey);
    await _dataProvider.setSecrets(secretsConfig);
  }
}
