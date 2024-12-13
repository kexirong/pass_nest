import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../models/account/account_group.dart';

import 'controllers/group_action_controller.dart';

class GroupActionView extends StatelessWidget {
  GroupActionView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupActionController());
    AccountGroup? group = Get.arguments as AccountGroup?;

    if (group != null) {
      controller.loadFromGroup(group);
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return PopScope<AccountGroup>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop) {
          return;
        }
        if (!controller.unSave) {
          Get.back();
          return;
        }
        var doPop = await Get.defaultDialog<bool>(
            title: '提示',
            onConfirm: () => Get.back<bool>(result: true),
            onCancel: () => {},
            buttonColor: colorScheme.tertiary,
            middleText: "确认放弃保存退出");
        if (doPop == true) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          title: Text(group == null ? '添加分组' : '编辑分组'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  Get.rawSnackbar(message: 'Processing Data');
                  return;
                }

                Get.back(result: controller.assignToGroup(group));
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GetBuilder<GroupActionController>(
            builder: (c) => Form(
              key: _formKey,
              child: Column(
                children: _buildFormField(context, c),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormField(BuildContext context, GroupActionController controller) {
    final List<Widget> rows = [
      Row(
        children: <Widget>[
          const Expanded(
            flex: 3,
            child: Text('title', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 7,
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              controller: controller.name,
              onChanged: (_) => controller.setUnSave(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please fill in this field';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          const Expanded(
            flex: 3,
            child: Text('description', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 7,
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              controller: controller.description,
              onChanged: (_) => controller.setUnSave(),
            ),
          ),
        ],
      ),
    ];
    return rows;
  }
}
