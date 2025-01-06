import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/accounts_service.dart';
import 'controllers/secret_controller.dart';

class SettingSecret extends StatelessWidget {
  SettingSecret({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return GetBuilder(
      init: SecretController(),
      builder: (controller) {
        var attSecrets = controller.attSecrets;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            title: const Text('加密密钥'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  textColor: colorScheme.primary,
                  title: const Text('主密钥'),
                ),
                Card.filled(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "原密钥"),
                            validator: (value) {
                              var mSecret = controller.mainSecret;
                              if (mSecret == null || mSecret.isEmpty) return null;
                              if (value == null || value.isEmpty) {
                                return '请输入原密钥';
                              } else if (value != mSecret) {
                                return '原密钥错误';
                              }
                              return null;
                            },
                            controller: controller.oldMainSecret,
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "新密钥"),
                            controller: controller.newMainSecret,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入新密钥';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "确认新密钥"),
                            controller: controller.confirmNewMainSecret,
                            validator: (value) {
                              if (value != controller.newMainSecret.text) {
                                return '新密钥不一致';
                              }
                              return null;
                            },
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 16),
                            child: OutlinedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                await controller.setMainSecret(controller.newMainSecret.text);
                                controller.reset();
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
                ListTile(
                  textColor: colorScheme.primary,
                  title: const Text(
                    '附加密钥',
                  ),
                ),
                Card.filled(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(height: 0);
                        },
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attSecrets.length,
                        itemBuilder: (BuildContext context, int index) {
                          final obscured = RxBool(true);
                          return Obx(
                            () => ListTile(
                              leading: GestureDetector(
                                child: Icon(
                                  obscured.value ? Icons.visibility_off : Icons.visibility,
                                  color: colorScheme.secondary,
                                ),
                                onTap: () {
                                  obscured.value = !obscured.value;
                                },
                              ),
                              title: Text(obscured.value ? '*******' : attSecrets[index].secret),
                              trailing: GestureDetector(
                                onTap: () {
                                  Get.defaultDialog(
                                      title: '请确认',
                                      textConfirm: '确认',
                                      textCancel: '取消',
                                      buttonColor: colorScheme.error,
                                      onConfirm: () async {
                                        await controller.deleteSecret(attSecrets[index].secret);
                                        Get.back();
                                      },
                                      middleText: "确认删除此密钥？");
                                },
                                child: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                              ),
                            ),
                          );
                        },
                      ),
                      attSecrets.isNotEmpty ? const Divider(height: 0) : const SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: const Text('添加'),
                            onPressed: () async {
                              var inputSecret = TextEditingController();
                              var result = await Get.dialog(AlertDialog(
                                title: const Text('添加附加密钥'),
                                content: TextField(
                                  controller: inputSecret,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("取消"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: const Text("确认"),
                                    onPressed: () {
                                      if (inputSecret.text.trim().isEmpty) {
                                        Get.rawSnackbar(message: '密钥不能为空');
                                        return;
                                      }
                                      Get.back(result: inputSecret.text.trim());
                                    },
                                  ),
                                ],
                              ));
                              if (result is String) {
                                await controller.addSecret(result);
                                Get.rawSnackbar(message: '添加成功');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card.filled(
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        if (kDebugMode) {
                          print('mainSecret:${controller.mainSecret}');
                        }
                        var ret = await Get.find<AccountsService>().reEncryptAccounts();
                        if (ret) {
                          Get.rawSnackbar(message: '重新加密完成');
                        }
                      },
                      child: const Text('重新加密'),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
