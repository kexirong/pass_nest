import 'dart:convert';

import 'package:sembast/sembast.dart';

import '../../../models/account/account_group.dart';

class AccountGroupStore {
  static const storeName = 'nest_account_group';
  final StoreRef<String, String> _store = StoreRef<String, String>(storeName);

  AccountGroupStore();

  Future<List<AccountGroup>> getAll(DatabaseClient dbc) async {
    var ngs = <AccountGroup>[];
    var records = await _store.find(dbc);
    for (var rec in records) {
      var jsonMap = jsonDecode(rec.value);
      ngs.add(AccountGroup.fromJson(jsonMap));
    }
    return ngs;
  }

  Future<AccountGroup?> get(DatabaseClient dbc, String key) async {
    var rec = await _store.record(key).get(dbc);
    if (rec == null) return null;
    var jsonMap = jsonDecode(rec);
    return AccountGroup.fromJson(jsonMap);
  }

  Future<String?> add(DatabaseClient dbc, AccountGroup ag) async {
    return await _store.record(ag.id).add(dbc, jsonEncode(ag));
  }

  Future<String?> update(DatabaseClient dbc, AccountGroup ag) async {
    return await _store.record(ag.id).put(dbc, jsonEncode(ag));
  }

  Future<String?> delete(DatabaseClient dbc, AccountGroup ag) async {
    return await _store.record(ag.id).delete(dbc);
  }
}
