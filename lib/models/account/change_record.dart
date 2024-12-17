import 'dart:convert';

enum RecordType { create, update, delete }

enum ItemType { group, account }

typedef ID = String;

class ChangeRecord {
  String id;
  ItemType itemType;
  RecordType recordType;
  int timestamp;

  ChangeRecord(this.id, this.itemType, this.recordType)
      : timestamp = DateTime.now().millisecondsSinceEpoch;

  ChangeRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        recordType = RecordType.values[json['record_type']],
        itemType = ItemType.values[json['item_type']],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'record_type': recordType.index,
        'item_type': itemType.index,
        'timestamp': timestamp
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

Map<ID, ChangeRecord> zipRecords(List<ChangeRecord> records) {
  Map<ID, ChangeRecord> recs = {};
  for (var rec in records) {
    var item = recs[rec.id];
    if (item == null) {
      recs[rec.id] = rec;
      continue;
    }

    if (item.recordType.index > rec.recordType.index) {
      continue;
    }

    recs[rec.id] = rec;
  }
  return recs;
}

List<ChangeRecord> diffRecords(Map<ID, ChangeRecord> records1, Map<ID, ChangeRecord> records2) {
  List<ChangeRecord> recs = [];
  for (var item2 in records2.values) {
    var item1 = records1[item2.id];
    if (item1 == null) {
      print('(item == null)');
      recs.add(item2);
      continue;
    }
    print('item1: $item1');
    print('item2: $item2');
    if (item2.timestamp > item1.timestamp || item2.recordType.index > item1.recordType.index) {
      print('   recs.add(records2[key]!);');
      recs.add(item2);
    }
  }
  return recs;
}
