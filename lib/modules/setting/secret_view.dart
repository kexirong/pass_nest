import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/secret_controller.dart';

class SettingSecret extends StatelessWidget {
  SettingSecret({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return GetBuilder(
      init: SecretController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          title: const Text('加密密码'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "原密码"),
                  validator: (value) {
                    var mSecret = controller.mainSecret;
                    if (mSecret == null || mSecret.isEmpty) return null;
                    if (value == null || value.isEmpty) {
                      return '请输入原密码';
                    } else if (value != mSecret) {
                      return '原密码错误';
                    }
                    return null;
                  },
                  controller: controller.oldMainSecret,
                ),
                TextFormField(
                    decoration: const InputDecoration(labelText: "密码"),
                    controller: controller.newMainSecret,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入新密码';
                      }
                      return null;
                    }),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      await controller.setMainSecret(controller.newMainSecret.text);
                      Get.rawSnackbar(message: '保存成功');
                    },
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
