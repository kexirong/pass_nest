import 'package:get/get.dart';
import '../models/account/account_group.dart';
import '../services/db/data_provider.dart';

class GroupsService extends GetxService {
  final _groups = <AccountGroup>[];
  final _dataProvider = Get.find<DataProviderService>();

  List<AccountGroup> get groups => _groups;
  bool isLoadedData = false;

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  Future<void> loadData([bool force = false]) async {
    if (isLoadedData && !force) return;
    _groups.clear();
    _groups.addAll(await _dataProvider.getAccountGroups());
    isLoadedData = true;
  }

  Future<void> addGroup(AccountGroup group) async {
    await _dataProvider.addAccountGroup(group);
    _groups.add(group);
  }

  AccountGroup getGroupByID(String id) {
    return _groups.firstWhere((element) => element.id == id);
  }

  Future<void> updateGroup(AccountGroup group) async {
    int index = _groups.indexWhere((el) => (el.id == group.id));
    if (index < 0) return;
    await _dataProvider.updateAccountGroup(group);
    _groups[index] = group;
  }

  Future<void> deleteGroup(AccountGroup group) async {
    await _dataProvider.deleteAccountGroup(group);
    _groups.removeWhere((e) => e.id == group.id);
  }
}
