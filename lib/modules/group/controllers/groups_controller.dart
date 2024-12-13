import 'package:get/get.dart';
import 'package:pass_nest/services/accounts_service.dart';

import '../../../models/account/account_group.dart';
import '../../../services/groups_service.dart';

class GroupsController extends GetxController {
  final _groupsService = Get.find<GroupsService>();
  final _accountsService = Get.find<AccountsService>();

  List<AccountGroup> get groups => _groupsService.groups;

  Future<void> addGroup(AccountGroup group) async {
    await _groupsService.addGroup(group);
    update();
  }

  int accountCount(String? groupID) {
    return _accountsService.getAccountsByGroupID(groupID).length;
  }

  Future<void> updateGroup(AccountGroup group) async {
    await _groupsService.updateGroup(group);
    update();
  }

  Future<void> deleteGroup(AccountGroup group) async {
    await _groupsService.deleteGroup(group);
    update();
  }
}
