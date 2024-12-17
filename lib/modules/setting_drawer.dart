import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class SettingDrawer extends StatelessWidget {
  const SettingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            padding: EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
            decoration: BoxDecoration(),
            child: Text('设置'),
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('加密'),
            onTap: () {
              Get.back();
              Get.toNamed(Paths.settingSecret);
            },
          ),
          const Divider(height: 0),
          //
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('同步'),
            onTap: () {
              Get.back();
              Get.toNamed(Paths.settingWebdav);
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            onTap: () {
              Get.back();
              Get.toNamed(Paths.settingInfo);
            },
          ),
        ],
      ),
    );
  }
}
