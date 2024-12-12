import 'dart:convert';

import '../../utils/util.dart';

class AccountGroup {
  String id, name;
  String? description;
  int createdAt;
  int updatedAt = 0;

  AccountGroup(this.name)
      : id = uuid(),
        createdAt = DateTime.now().millisecondsSinceEpoch;

  factory AccountGroup.copy(AccountGroup group) {
    return AccountGroup.fromJson(group.toJson());
  }

  AccountGroup.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
