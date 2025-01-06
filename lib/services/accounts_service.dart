import 'package:get/get.dart';

import '../models/account/account.dart';
import '../services/db/data_provider.dart';
import '../services/config_service.dart';

class AccountsService extends GetxService {
  final _accounts = <BaseAccount>[];
  final _dataProvider = Get.find<DataProviderService>();
  final _configService = Get.find<ConfigService>();

  bool isLoadedData = false;

  List<BaseAccount> get accounts => _accounts;

  Future<void> loadData([bool force = false]) async {
    if (isLoadedData && !force) return;
    isLoadedData = true;
    _accounts.clear();
    _accounts.addAll(await _dataProvider.getAccounts());
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  List<BaseAccount> getAccountsByGroupID(String? groupID) {
    return _accounts.where((element) => element.groupID == groupID).toList();
  }

  String? getSecret(String mKey) {
    return _configService.getSecret(mKey);
  }

  BaseAccount? getAccountByID(String id) {
    return _accounts.firstWhereOrNull((element) => element.id == id);
  }

  Future<void> addAccount(BaseAccount account) async {
    var masterSecret = _configService.mainSecret;
    if (account is PlainAccount && masterSecret != null && masterSecret.isNotEmpty) {
      account = account.encrypt(masterSecret);
    }
    await _dataProvider.addAccount(account);
    _accounts.add(account);
  }

  Future<void> updateAccount(BaseAccount account) async {
    var masterSecret = _configService.mainSecret;
    int index = _accounts.indexWhere((el) => (el.id == account.id));
    if (index < 0) return;
    account.updatedAt = DateTime.now().millisecondsSinceEpoch;
    if (account is PlainAccount && masterSecret != null && masterSecret.isNotEmpty) {
      account = account.encrypt(masterSecret);
    }
    await _dataProvider.accountUpdate(account);

    _accounts[index] = account;
  }

  Future<void> deleteAccount(BaseAccount account) async {
    await _dataProvider.accountDelete(account);
    _accounts.removeWhere((e) => e.id == account.id);
  }

  Future<bool> reEncryptAccounts() async {
    var mSecret = _configService.mainSecret;
    if (mSecret == null) return false;
    for (var acct in accounts) {
      if (acct is EncryptAccount) {
        //已加密数据重新加密
        //使用当前主密钥加密的数据不处理
        if (_configService.isMainSecret(acct.mKey)) {
          continue;
        }
        var secret = _configService.getSecret(acct.mKey);
        //跳过无法解密的数据
        if (secret == null) continue;
        acct = acct.decrypt(secret);
      }
      //使用主密钥进行加密
      acct = (acct as PlainAccount).encrypt(mSecret);
      await updateAccount(acct);
    }
    return true;
  }
}
