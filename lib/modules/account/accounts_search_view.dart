import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/account/account.dart';
import '../../routes/app_pages.dart';
import 'controllers/accounts_controller.dart';
import 'widgets/accounts_list_widget.dart';
import 'widgets/account_detail_widget.dart';

class AccountsSearchView extends StatelessWidget {
  const AccountsSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("###################build home###########################");
    }
    String filter = '';
    var controller = Get.put(AccountsController());
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        title: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索',
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: colorScheme.onPrimary,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onChanged: (value) {
              filter = value.trim();
              controller.update();
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var result = await Get.toNamed(Paths.accountAction);
              if (result is PlainAccount) {
                controller.addAccount(result);
                Get.rawSnackbar(message: '添加成功');
              }
            },
          ),
        ],
      ),
      body: GetBuilder<AccountsController>(
        builder: (controller) {
          List<BaseAccount> accounts;
          var groupID = Get.parameters['group_id'];
          switch (groupID) {
            case (null):
              accounts = controller.accounts;
            case ('null'):
              accounts = controller.getAccountsByGroupID(null);
            default:
              accounts = controller.getAccountsByGroupID(groupID);
          }
          if (filter.isNotEmpty) {
            accounts = accounts.where((acct) => acct.title.contains(filter.trim())).toList();
          }
          PlainAccount? decryptAccount(BaseAccount account) {
            if (account is EncryptAccount) {
              var secret = controller.getSecret(account.mKey);
              if (secret != null) {
                return account.decrypt(secret);
              }
              return null;
            }
            return account as PlainAccount;
          }

          return AccountsListWidget(
            accounts,
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
                  await Get.dialog(AccountDetailWidget(account: acct));
                case (AccountEvent.update):
                  var result = await Get.toNamed(Paths.accountAction, arguments: acct);
                  if (result is PlainAccount) {
                    await controller.updateAccount(result);
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
    );
  }
}
