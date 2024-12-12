import 'dart:convert';

import 'package:sembast/sembast.dart';

import '../../../models/account/account.dart';

class AccountStore {
  static const storeName = 'nest_account';
  final StoreRef<String, String> _store = StoreRef<String, String>(storeName);

  AccountStore();

  Future<List<BaseAccount>> getAll(DatabaseClient dbc) async {
    var bas = <BaseAccount>[];
    var records = await _store.find(dbc);
    for (var rec in records) {
      var jsonMap = jsonDecode(rec.value) as Map<String, dynamic>;

      if (jsonMap.containsKey('cipher')) {
        bas.add(EncryptAccount.fromJson(jsonMap));
      } else {
        bas.add(PlainAccount.fromJson(jsonMap));
      }
    }
    return bas;
  }

  Future<BaseAccount?> get(DatabaseClient dbc, String key) async {
    var rec = await _store.record(key).get(dbc);
    if (rec == null) return null;
    var jsonMap = jsonDecode(rec) as Map<String, dynamic>;
    if (jsonMap.containsKey('cipher')) {
      return EncryptAccount.fromJson(jsonMap);
    }
    return PlainAccount.fromJson(jsonMap);
  }

  Future<String?> add(DatabaseClient dbc, BaseAccount ba) async {
    return await _store.record(ba.id).add(dbc, jsonEncode(ba));
  }

  Future<String?> update(DatabaseClient dbc, BaseAccount ba) async {
    return await _store.record(ba.id).put(dbc, jsonEncode(ba));
  }

  Future<String?> delete(DatabaseClient dbc, BaseAccount ba) async {
    return await _store.record(ba.id).delete(dbc);
  }
}
