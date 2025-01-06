import 'dart:convert';

enum RecordType { create, update, delete }

enum ItemType { group, account }

typedef ID = String;

class ChangeRecord {
  String id;
  ItemType itemType;
  RecordType recordType;
  int timestamp;

  ChangeRecord(this.id, this.itemType, this.recordType, this.timestamp);

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
