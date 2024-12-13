import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/webdav_config.dart';

import '../../../services/config_service.dart';

class SyncController extends GetxController {
  final _configService = Get.find<ConfigService>();
  final webdav = _Webdav();
  SyncMethod? syncMethod;

  @override
  void onInit() {
    _configService.getWebdavConfig().then((conf) {
      if (conf == null) return;
      webdav.assign(conf);
      update();
    });
    super.onInit();
  }

  Future<void> saveWebdav() async {
    final conf = webdav.toWebdavConfig();
    if (conf == null) return;
    await _configService.setWebdavConfig(conf);
  }

  @override
  void onClose() {
    webdav.dispose();
    super.onClose();
  }
}

class _Webdav {
  final TextEditingController url = TextEditingController();

  final TextEditingController user = TextEditingController();

  final TextEditingController password = TextEditingController();

  final TextEditingController path = TextEditingController();

  void dispose() {
    url.dispose();
    user.dispose();
    password.dispose();
    path.dispose();
  }

  WebdavConfig? toWebdavConfig() {
    if (url.text.trim().isEmpty || user.text.trim().isEmpty || password.text.trim().isEmpty) {
      return null;
    }
    return WebdavConfig(
      url.text.trim(),
      user.text.trim(),
      password.text.trim(),
      path.text.trim(),
    );
  }

  void assign(WebdavConfig conf) {
    url.text = conf.url;
    user.text = conf.user;
    password.text = conf.password;
    path.text = conf.path;
  }
}
