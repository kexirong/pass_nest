import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/secret_config.dart';
import '../../../services/config_service.dart';

class SecretController extends GetxController {
  final _configService = Get.find<ConfigService>();

  late final TextEditingController oldMainSecret;

  late final TextEditingController newMainSecret;
  late final TextEditingController confirmNewMainSecret;

  List<SecretConfig> get attSecrets =>
      _configService.secretsConfig.where((s) => !s.isMain).toList();

  String? get mainSecret => _configService.mainSecret;

  Future<void> setMainSecret(String secret) async {
    await _configService.setMainSecret(secret);
  }

  Future<void> addSecret(String secret) async {
    await _configService.addSecret(secret);
    update();
  }

  Future<void> deleteSecret(String secret) async {
    await _configService.deleteSecret(secret);
    update();
  }

  void reset() {
    oldMainSecret.text = '';
    newMainSecret.text = '';
    confirmNewMainSecret.text = '';
    update();
  }

  @override
  void onInit() {
    oldMainSecret = TextEditingController();
    newMainSecret = TextEditingController();
    confirmNewMainSecret = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    oldMainSecret.dispose();
    newMainSecret.dispose();
    confirmNewMainSecret.dispose();
    super.onClose();
  }
}
