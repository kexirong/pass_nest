import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'controllers/groups_controller.dart';
import '../../routes/app_pages.dart';
import '../../models/account/account_group.dart';

class GroupsView extends StatelessWidget {
  GroupsView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("###################build groups###########################");
    }
    var controller = Get.put(GroupsController());
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('分组'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var result = await Get.toNamed(Paths.groupAction);
              if (result is AccountGroup) {
                controller.addGroup(result);
              }
            },
          ),
        ],
      ),
      body: GetBuilder<GroupsController>(
        // init: GroupsController(),
        builder: (controller) {
          var colorScheme = Theme.of(context).colorScheme;
          if (kDebugMode) {
            print("###################build Account###########################");
          }
          //默认组的group_id==null,empty则全部

          var groups = controller.groups;

          return SlidableAutoCloseBehavior(
            child: ListView.separated(
              itemCount: groups.length + 1,
              itemBuilder: (BuildContext context, int index) {
                AccountGroup? group;
                if (index > 0) {
                  group = AccountGroup.copy(groups[index - 1]);
                }

                return Slidable(
                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          if (group == null) return;
                          var result = await Get.toNamed(Paths.groupAction, arguments: group);

                          if (result is AccountGroup) {
                            controller.updateGroup(result);
                          }
                        },
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.surface,
                        icon: Icons.edit,
                        label: '编辑',
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          if (group != null) {
                            controller.deleteGroup(group);
                          }
                        },
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.surface,
                        icon: Icons.delete,
                        label: '删除',
                      ),
                    ],
                  ),

                  child: ListTile(
                    title: Text(group?.name ?? '默认'),
                    subtitle: Text(
                      group == null ? '默认组不可删除编辑' : group.description ?? '',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                    onTap: () {
                      Get.toNamed(Paths.accountsWithGroupID,
                          parameters: {'group_id': '${group?.id}'});
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 0);
              },
            ),
          );
        },
      ),
      // drawer: const SettingWidget(),
    );
  }
}
