import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/account/account_group.dart';
import '../../../models/account/account.dart';
import '../../../services/groups_service.dart';

class ExtendField {
  final TextEditingController name;
  final TextEditingController value;

  ExtendField()
      : name = TextEditingController(),
        value = TextEditingController();

  void dispose() {
    name.dispose();
    value.dispose();
  }
}

class AccountActionController extends GetxController {
  final _groupsService = Get.find<GroupsService>();

  bool _unSave = false;

  void setUnSave() {
    _unSave = true;
  }

  bool get unSave => _unSave;

  List<AccountGroup> get groups => _groupsService.groups;

  late final TextEditingController title;

  String? groupID;
  late final TextEditingController url;

  late final TextEditingController username;

  late final TextEditingController password;

  List<ExtendField> extendFields = [];

  void addExtendField() {
    extendFields.add(ExtendField());
    update();
  }

  void removeExtendField(ExtendField f) {
    extendFields.remove(f);
    update();
  }

  void loadFromAccount(PlainAccount account) {
    title.text = account.title;
    groupID = account.groupID;
    if (account.url != null) {
      url.text = account.url!;
    }
    username.text = account.username;

    password.text = account.password;
    if (account.extendField.isNotEmpty) {
      account.extendField.forEach((key, value) {
        var ef = ExtendField();
        ef.name.text = key;
        ef.value.text = value;
        extendFields.add(ef);
      });
    }
    update();
  }

  PlainAccount assignToAccount(PlainAccount? account) {
    if (account == null) {
      account = PlainAccount(title.text.trim(), username.text.trim(), password.text.trim());
    } else {
      account.title = title.text.trim();
      account.username = username.text.trim();
      account.password = password.text.trim();
    }
    account.groupID = groupID;
    if (url.text.trim().isNotEmpty) {
      account.url = url.text.trim();
    }
    if (extendFields.isNotEmpty) {
      account.extendField = {for (var e in extendFields) e.name.text: e.value.text};
    }
    return account;
  }

  void reset() {
    title.text = '';
    groupID = null;
    url.text = '';
    username.text = '';
    password.text = '';
    extendFieldsDispose();
    extendFields.clear();
    update();
  }

  @override
  void onInit() {
    title = TextEditingController();
    url = TextEditingController();
    username = TextEditingController();
    password = TextEditingController();

    super.onInit();
  }

  void extendFieldsDispose() {
    for (var f in extendFields) {
      f.dispose();
    }
  }

  @override
  void onClose() {
    title.dispose();
    url.dispose();
    username.dispose();
    password.dispose();
    extendFieldsDispose();
    super.onClose();
  }
}
