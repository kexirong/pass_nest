import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pass_nest/modules/account/widgets/gen_password_dialog.dart';
import '../../models/account/account.dart';
import '../../models/account/account_group.dart';

import 'controllers/account_action_controller.dart';

class AccountActionView extends StatelessWidget {
  AccountActionView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountActionController());
    PlainAccount? account = Get.arguments as PlainAccount?;

    if (account != null) {
      controller.loadFromAccount(account);
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return PopScope<PlainAccount>(
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
          title: Text(account == null ? '添加账号' : '编辑账号'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                Get.back(result: controller.assignToAccount(account));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GetBuilder<AccountActionController>(
                  builder: (c) => Form(
                    key: _formKey,
                    child: Column(
                      children: _buildFormField(context, c),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OverflowBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton(
                        onPressed: () {
                          Get.dialog(const GenPasswordDialog());
                        },
                        child: const Text(
                          "随机密码",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        )),
                    OutlinedButton(
                      onPressed: () {
                        controller.reset();
                        Get.rawSnackbar(message: 'ok');
                      },
                      child: const Text(
                        "重置",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        controller.addExtendField();
                      },
                      child: const Text(
                        "添加字段",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormField(BuildContext context, AccountActionController controller) {
    final List<Widget> rows = [
      Row(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Text('title', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              controller: controller.title,
              validator: notEmptyValidator,
              onChanged: (_) => controller.setUnSave(),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Text('group_id', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              iconSize: 32,
              value: controller.groupID,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? value) {
                controller.groupID = value;
              },
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('default'),
                ),
                ...controller.groups.map<DropdownMenuItem<String>>((AccountGroup group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(
                      group.name,
                      textAlign: TextAlign.end,
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Text('url', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              controller: controller.url,
              onChanged: (_) => controller.setUnSave(),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Text('username', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              controller: controller.username,
              onChanged: (_) => controller.setUnSave(),
              validator: notEmptyValidator,
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Text('password', style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4, left: 2),
            child: Text(':', style: TextStyle(fontSize: 20)),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              controller: controller.password,
              onChanged: (_) => controller.setUnSave(),
              validator: notEmptyValidator,
            ),
          ),
        ],
      ),
    ];
    if (controller.extendFields.isNotEmpty) {
      rows.add(
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(child: Divider(height: 0)),
              Text('扩展字段'),
              Expanded(child: Divider(height: 0)),
            ],
          ),
        ),
      );
    }
    for (var f in controller.extendFields) {
      rows.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextFormField(
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                controller: f.name,
                onChanged: (_) => controller.setUnSave(),
                validator: notEmptyValidator,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 4, left: 2),
              child: Text(':', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                controller: f.value,
                onChanged: (_) => controller.setUnSave(),
                validator: notEmptyValidator,
              ),
            ),
            GestureDetector(
              child: Icon(
                Icons.remove_circle_outline,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: () {
                controller.removeExtendField(f);
              },
            ),
          ],
        ),
      );
    }
    return rows;
  }

  String? notEmptyValidator(value) {
    if (value == null || value.isEmpty) {
      return 'please fill in this field';
    }
    return null;
  }
}
