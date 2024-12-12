import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../models/account/account.dart';

enum AccountEvent { tap, update, delete }

typedef AccountEventCallback = void Function(AccountEvent event, BaseAccount account);
typedef AccountSubtitleCallback = Widget? Function(BaseAccount account);

class AccountsListWidget extends StatelessWidget {
  const AccountsListWidget(this.accounts,
      {this.accountSubtitle, required this.eventCallback, super.key});

  final List<BaseAccount> accounts;
  final AccountSubtitleCallback? accountSubtitle;
  final AccountEventCallback? eventCallback;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: accounts.length,
        itemBuilder: (BuildContext context, int index) {
          var account = BaseAccount.copy(accounts[index]);

          return Slidable(
            // key: ValueKey(index),

            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => eventCallback?.call(AccountEvent.update, account),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.surface,
                  icon: Icons.edit,
                  label: '编辑',
                ),
                SlidableAction(
                  onPressed: (_) => eventCallback?.call(AccountEvent.delete, account),
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.surface,
                  icon: Icons.delete,
                  label: '删除',
                ),
              ],
            ),
            child: ListTile(
              title: Text(account.title),
              subtitle: accountSubtitle?.call(account),
              onTap: () => eventCallback?.call(AccountEvent.tap, account),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0);
        },
      ),
    );
  }
}
