import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class SettingDrawer extends StatelessWidget {
  const SettingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
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
              Get.toNamed(Paths.settingSecret);
            },
          ),
          const Divider(height: 0),
          //
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('同步'),
            onTap: () {

            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}
