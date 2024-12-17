import 'dart:convert';

import 'package:sembast/sembast.dart';
import '../../../models/account/change_record.dart';

class ChangeRecordStore {
  static const storeName = 'nest_record_change';
  final StoreRef<String, String> _store = StoreRef<String, String>(storeName);

  ChangeRecordStore();

  Future<List<ChangeRecord>> getAll(DatabaseClient dbc) async {
    var crs = <ChangeRecord>[];
    var records = await _store.find(dbc);
    for (var rec in records) {
      var jsonMap = jsonDecode(rec.value);
      crs.add(ChangeRecord.fromJson(jsonMap));
    }
    return crs;
  }

  Future<ChangeRecord?> get(DatabaseClient dbc, String key) async {
    var rec = await _store.record(key).get(dbc);
    if (rec == null) return null;
    var jsonMap = jsonDecode(rec);
    return ChangeRecord.fromJson(jsonMap);
  }

  Future<String?> add(DatabaseClient dbc, ChangeRecord cr) async {
    return await _store.add(dbc, jsonEncode(cr));
  }
// delete is not allowed
// Future<void> delete
}
