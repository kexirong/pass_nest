import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/account/account_group.dart';
import '../../../services/groups_service.dart';

class GroupActionController extends GetxController {
  final _groupsService = Get.find<GroupsService>();

  List<AccountGroup> get groups => _groupsService.groups;

  late final TextEditingController name;

  late final TextEditingController description;

  bool _unSave = false;

  void setUnSave() {
    _unSave = true;
  }

  bool get unSave => _unSave;

  void loadFromGroup(AccountGroup group) {
    name.text = group.name;

    if (group.description != null) {
      description.text = group.description!;
    }

    update();
  }

  AccountGroup assignGroup(AccountGroup? group) {
    if (group == null) {
      group = AccountGroup(name.text.trim());
    } else {
      group.name = name.text.trim();
    }

    if (description.text.trim().isNotEmpty) {
      group.description = description.text.trim();
    }

    return group;
  }

  @override
  void onInit() {
    name = TextEditingController();
    description = TextEditingController();

    super.onInit();
  }

  @override
  void onClose() {
    name.dispose();
    description.dispose();

    super.onClose();
  }
}
