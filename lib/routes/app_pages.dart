import 'package:get/get.dart';

import '../modules/account/accounts_search_view.dart';
import '../modules/group/group_action_view.dart';
import '../modules/group/groups_view.dart';
import '../modules/setting/secret_view.dart';

import '../modules/account/accounts_home_view.dart';
import '../modules/account/account_action_view.dart';
import '../modules/setting/sync_view.dart';

part 'app_paths.dart';

class AppPages {
  AppPages._();

  static const initial = Paths.accounts;

  static final routes = [
    GetPage(
      name: Paths.accounts,
      page: () => AccountsHomeView(),
    ),
    GetPage(
      name: Paths.accountsSearch,
      page: () => const AccountsSearchView(),
    ),
    GetPage(
      name: Paths.accountsWithGroupID,
      page: () => const AccountsSearchView(),
    ),
    GetPage(
      name: Paths.accountAction,
      page: () => AccountActionView(),
    ),
    GetPage(
      name: Paths.groups,
      page: () => GroupsView(),
    ),
    GetPage(
      name: Paths.groupAction,
      page: () => GroupActionView(),
    ),
    GetPage(
      name: Paths.settingSecret,
      page: () => SettingSecret(),
    ),
    GetPage(
      name: Paths.settingWebdav,
      page: () => SettingSync(),
    ),
  ];
}
