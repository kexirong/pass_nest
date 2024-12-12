import 'dart:convert';



class SecretConfig {
  bool isMain;
  String secret;
  int createdAt;

  SecretConfig(this.secret, {this.isMain = false})
      : createdAt = DateTime.now().millisecondsSinceEpoch;

  SecretConfig.fromJson(Map<String, dynamic> json)
      : secret = json['secret'],
        isMain = json['is_main'],
        createdAt = json['created_at'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'secret': secret,
        'is_main': isMain,
        'created_at': createdAt,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
