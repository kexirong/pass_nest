import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/account/account.dart';
import '../../routes/app_pages.dart';
import '../setting_drawer.dart';
import 'controllers/accounts_controller.dart';
import 'widgets/accounts_list_widget.dart';
import 'widgets/account_detail_widget.dart';

class AccountsHomeView extends StatelessWidget {
  AccountsHomeView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("###################build home###########################");
    }
    var controller = Get.put(AccountsController());
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        foregroundColor: colorScheme.surface,
        backgroundColor: colorScheme.tertiary,
        shape: const CircleBorder(),
        onPressed: () async {
          var result = await Get.toNamed(Paths.accountAction);

          if (result is PlainAccount) {
            controller.addAccount(result);
            Get.rawSnackbar(message: '添加成功');
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('AccountsHome'),
        leading: IconButton(
          icon: const Icon(Icons.grid_view_outlined),
          onPressed: () {
            Get.toNamed(Paths.groups);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.toNamed(Paths.accountsSearch);
            },
          ),
          IconButton(
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            icon: const Icon(Icons.settings_outlined),
          )
        ],
      ),
      body: GetBuilder<AccountsController>(
        builder: (controller) {
          PlainAccount? decryptAccount(BaseAccount account) {
            if (account is EncryptAccount) {
              print('account ${account.id}   start decrypt  ');

              var secret = controller.getSecret(account.mKey);

              print('get secret by ${account.mKey} :$secret');
              if (secret != null) {
                print('account ${account.id} decrypt complete ');
                return account.decrypt(secret);
              }
              return null;
            }
            return account as PlainAccount;
          }

          return AccountsListWidget(
            controller.accounts,
            accountSubtitle: (BaseAccount account) {
              String getUrl(BaseAccount account) {
                var acct = decryptAccount(account);
                return acct == null ? '***未能解密***' : acct.url ?? '';
              }

              return Text(
                overflow: TextOverflow.ellipsis,
                'URL: ${getUrl(account)}',
                style: TextStyle(color: colorScheme.outline),
              );
            },
            eventCallback: (AccountEvent event, BaseAccount account) async {
              var acct = decryptAccount(account);
              if (acct == null) {
                Get.rawSnackbar(message: '未能解密，请设置密码');
                return;
              }
              switch (event) {
                case (AccountEvent.tap):
                  await Get.dialog(AccountDetailWidget(
                    account: acct,
                  ));
                case (AccountEvent.update):
                  var result = await Get.toNamed(Paths.accountAction, arguments: acct);
                  if (result is PlainAccount) {
                    await controller.updateAccount(acct);
                    Get.rawSnackbar(message: '保存成功');
                  }
                case (AccountEvent.delete):
                  await controller.deleteAccount(acct);
                  Get.rawSnackbar(message: '删除成功');
              }
            },
          );
        },
      ),
      drawer: const SettingDrawer(),
    );
  }
}
