import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../models/account/account.dart';

class AccountDetailWidget extends StatelessWidget {
  final PlainAccount account;

  const AccountDetailWidget({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var fieldMap = <String, String>{
      '账号': account.username,
      '密码': account.password,
      'URL': account.url ?? ''
    }..addAll(account.extendField);

    var extend = <Widget>[];
    fieldMap.forEach(
      (String k, String v) {
        extend.add(
          Row(
            children: <Widget>[
              Expanded(flex: 7, child: Text('$k: $v', overflow: TextOverflow.ellipsis)),
              Expanded(
                flex: 1,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(
                    Icons.content_copy,
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: v));
                    Get.rawSnackbar(message: '已复制到剪贴板');
                  },
                ),
              )
            ],
          ),
        );
      },
    );

    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                account.title,
                style: const TextStyle(fontSize: 22),
              ),
            ],
          ),
          ...extend,
        ],
      ),
    );
  }
}
