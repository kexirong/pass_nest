import 'package:get/get.dart';

import '../../../models/account/account.dart';
import '../../../services/accounts_service.dart';
import '../../../services/webdav/sync_webdav.dart';

class AccountsController extends GetxController {
  final _accountsService = Get.find<AccountsService>();

  List<BaseAccount> get accounts => _accountsService.accounts;

  List<BaseAccount> getAccountsByGroupID(String? groupID) {
    return _accountsService.getAccountsByGroupID(groupID);
  }

  Future<void> addAccount(BaseAccount account) async {
    await _accountsService.addAccount(account);
    update();
  }

  Future<void> updateAccount(BaseAccount account) async {
    await _accountsService.updateAccount(account);
    update();
  }

  Future<void> deleteAccount(BaseAccount account) async {
    await _accountsService.deleteAccount(account);
    update();
  }

  String? getSecret(String mKey) {
    return _accountsService.getSecret(mKey);
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    super.update(ids, condition);
    Get.find<SyncWebdavService>().notifySync();
  }

  @override
  void onReady() {
    _accountsService.loadData().then((_) => update());
  }
}
