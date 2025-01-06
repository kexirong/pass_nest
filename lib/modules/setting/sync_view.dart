import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_nest/models/webdav_config.dart';
import 'package:pass_nest/services/webdav/sync_webdav.dart';
import 'controllers/sync_controller.dart';

class SettingSync extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  SettingSync({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('同步'),
      ),
      body: GetBuilder(
        init: SyncController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Card.filled(
                    margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Expanded(child: Text('同步方式')),
                        DropdownButton<SyncMethod>(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          value: controller.syncMethod,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (SyncMethod? value) async {
                            controller.syncMethod = value;

                            controller.saveSyncMethod();
                            Get.rawSnackbar(message: '设置成功');
                          },
                          items: SyncMethod.values
                              .map<DropdownMenuItem<SyncMethod>>((SyncMethod value) {
                            return DropdownMenuItem<SyncMethod>(
                              value: value,
                              child: Text(value.name),
                            );
                          }).toList(),
                        ),
                      ],
                    )),
                ListTile(
                  textColor: colorScheme.primary,
                  title: const Text('Webdav'),
                ),
                Card.filled(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: "url"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'URL不能为空';
                              }
                              if (!GetUtils.isURL(value)) {
                                return '请输入正确URL';
                              }
                              return null;
                            },
                            controller: controller.webdav.url,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: "user"),
                            controller: controller.webdav.user,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'User不能为空';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "password"),
                            controller: controller.webdav.password,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password不能为空';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: "path"),
                            controller: controller.webdav.path,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: OutlinedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                var test = await controller.webdav.ping();
                                if (test) {
                                  Get.rawSnackbar(message: '连接成功');
                                } else {
                                  Get.rawSnackbar(message: '请检查配置');
                                }
                              },
                              child: const Text('测试'),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                await controller.saveWebdav();
                                Get.find<SyncWebdavService>().clientClose();
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
                Card.filled(
                  margin: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.find<SyncWebdavService>().notifySync();
                      },
                      child: const Text('立即同步'),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
