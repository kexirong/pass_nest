import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

import '../../models/account/account.dart';
import '../../models/account/account_group.dart';
import '../../models/account/change_record.dart';
import '../../models/webdav_config.dart';
import '../../models/secret_config.dart';

import '../../share/info.dart';
import 'factory.dart';
import 'store/account_group_store.dart';
import 'store/change_record_store.dart';
import 'store/account_store.dart';
import 'store/setting_store.dart';

class DataProviderService extends GetxService {
  Database? _db;
  final _dbName = 'note.db';

  Future<DataProviderService> init() async {
    await _init();
    return this;
  }

  Future<Database> get db async {
    return _db ?? await _init();
  }

  Future<String> getDeviceID() async {
    return await SettingStore().getDeviceID(await db);
  }

  Future<List<SecretConfig>> getSecrets() async {
    return await SettingStore().getSecrets(await db);
  }

  Future<void> setSecrets(List<SecretConfig> secrets) async {
    await SettingStore().setSecrets(await db, secrets);
  }

  Future<void> setWebdavConfig(WebdavConfig conf) async {
    await SettingStore().setWebdavConfig(await db, conf);
  }

  Future<WebdavConfig?> getWebdavConfig() async {
    return await SettingStore().getWebdavConfig(await db);
  }

  Future<void> setSyncMethod(SyncMethod method) async {
    await SettingStore().setSyncMethod(await db, method.name);
  }

  Future<SyncMethod> getSyncMethod() async {
    var method = await SettingStore().getSyncMethod(await db);
    return SyncMethod.values.firstWhere((e) => e.name == method, orElse: () => SyncMethod.off);
  }

  Future<List<AccountGroup>> getAccountGroups() async {
    return await AccountGroupStore().getAll(await db);
  }

  Future<void> addAccountGroup(AccountGroup group) async {
    var rm = ChangeRecord(group.id, ItemType.group, RecordType.create);
    var dbc = await db;
    await dbc.transaction((txn) async {
      await AccountGroupStore().add(txn, group);
      await ChangeRecordStore().add(txn, rm);
    });
  }

  Future<void> updateAccountGroup(AccountGroup group) async {
    group.updatedAt = DateTime.now().millisecondsSinceEpoch;
    var rm = ChangeRecord(group.id, ItemType.group, RecordType.update);
    var dbc = await db;
    await dbc.transaction((txn) async {
      await AccountGroupStore().update(txn, group);
      await ChangeRecordStore().add(txn, rm);
    });
  }

  Future<void> deleteAccountGroup(AccountGroup group) async {
    var rm = ChangeRecord(group.id, ItemType.group, RecordType.delete);
    var dbc = await db;
    await dbc.transaction((txn) async {
      await AccountGroupStore().delete(txn, group);
      await ChangeRecordStore().add(txn, rm);
    });
  }

  Future<List<BaseAccount>> getAccounts() async {
    return await AccountStore().getAll(await db);
  }

  Future<void> addAccount(BaseAccount account) async {
    var rm = ChangeRecord(account.id, ItemType.account, RecordType.create);
    var dbc = await db;
    await dbc.transaction((txn) async {
      await AccountStore().add(txn, account);
      await ChangeRecordStore().add(txn, rm);
    });
  }

  Future<void> accountUpdate(BaseAccount account) async {
    account.updatedAt = DateTime.now().millisecondsSinceEpoch;
    var rm = ChangeRecord(account.id, ItemType.account, RecordType.update);
    var dbc = await db;
    await dbc.transaction((txn) async {
      await AccountStore().update(txn, account);
      await ChangeRecordStore().add(txn, rm);
    });
  }

  Future<void> accountDelete(BaseAccount account) async {
    // int index = _accounts.indexWhere((el) => (el.id == accountID));
    //
    // if (index < 0) return;
    var rm = ChangeRecord(account.id, ItemType.account, RecordType.delete);
    var dbc = await db;
    await dbc.transaction((txn) async {
      await AccountStore().delete(txn, account);
      await ChangeRecordStore().add(txn, rm);
    });
  }

  Future<List<ChangeRecord>> getChangeRecords() async {
    return await ChangeRecordStore().getAll(await db);
  }

  Future<Database> _init() async {
    await _db?.close();
    var path = await _buildDatabasesPath();
    return _db = await databaseFactory.openDatabase(path);
  }

  Future<String> _buildDatabasesPath() async {
    if (GetPlatform.isWeb) {
      return _dbName;
    }
    var docDir = await getApplicationDocumentsDirectory();
    var dbPath = join(docDir.path, packageName);
    var dir = Directory(dbPath);

    //let exception propagate
    await dir.create(recursive: true);
    return join(dbPath, _dbName);
  }

  @override
  void onClose() {
    _db!.close();
    _db = null;
    super.onClose();
  }
}
