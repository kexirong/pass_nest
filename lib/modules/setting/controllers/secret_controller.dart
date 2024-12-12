import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/secret_config.dart';
import '../../../services/config_service.dart';

class SecretController extends GetxController {
  final _configService = Get.find<ConfigService>();

  late final TextEditingController oldMainSecret;

  late final TextEditingController newMainSecret;

  List<SecretConfig> get secrets => _configService.secretsConfig;

  String? get mainSecret => _configService.mainSecret;

  Future<void> setMainSecret(String secret) async {
    await _configService.setMainSecret(secret);
  }

  @override
  void onInit() {
    oldMainSecret = TextEditingController();
    newMainSecret = TextEditingController();

    super.onInit();
  }

  @override
  void onClose() {
    oldMainSecret.dispose();
    newMainSecret.dispose();
    super.onClose();
  }
}
