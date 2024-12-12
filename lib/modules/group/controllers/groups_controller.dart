import 'package:get/get.dart';

import '../../../models/account/account_group.dart';
import '../../../services/groups_service.dart';

class GroupsController extends GetxController {
  final _groupsService = Get.find<GroupsService>();

  List<AccountGroup> get groups => _groupsService.groups;

  Future<void> addGroup(AccountGroup group) async {
    await _groupsService.addGroup(group);
    update();
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
