import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import '../../utils/util.dart';

class BaseAccount {
  String id;
  String title;
  String? groupID;
  int createdAt;
  int updatedAt = 0;

  BaseAccount(this.title, {String? id, int? createdAt})
      : id = id ?? uuid(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  BaseAccount.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        groupID = json['group_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'group_id': groupID,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory BaseAccount.copy(BaseAccount acct) {
    if (acct is PlainAccount) {
      return PlainAccount.fromJson(acct.toJson());
    }
    if (acct is EncryptAccount) {
      return EncryptAccount.fromJson(acct.toJson());
    }
    return BaseAccount.fromJson(acct.toJson());
  }

  String getUsername() {
    if (this is EncryptAccount) {
      return '***未解密***';
    }
    return (this as PlainAccount).username ?? '';
  }
}

class PlainAccount extends BaseAccount {
  String username, password;
  String? url;
  Map<String, String> extendField = {};

  PlainAccount(super.title, this.username, this.password);

  PlainAccount.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        username = json['username'],
        password = json['password'],
        super.fromJson(json) {
    json['extend_field'].forEach((key, value) {
      if (value is String) {
        extendField[key] = value;
      }
    });
  }

  Map<String, dynamic> _toJson() => <String, dynamic>{
        'url': url,
        'username': username,
        'password': password,
        'extend_field': extendField
      };

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json.addAll(_toJson());
    return json;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  EncryptAccount encrypt(String password) {
    var iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(keyFromPassword(password), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(
      jsonEncode(_toJson()),
      iv: iv,
    );
    var eAccount = EncryptAccount(
      title,
      iv.base64,
      md5.convert(utf8.encode(password)).toString(),
      encrypted.base64,
      DateTime.now().millisecondsSinceEpoch,
      id: id,
      createdAt: createdAt,
    );
    eAccount.groupID = groupID;
    eAccount.updatedAt = eAccount.encryptedAt;
    return eAccount;
  }

  void assign(PlainAccount acct) {
    id = acct.id;
    title = acct.title;
    groupID = acct.groupID;
    createdAt = acct.createdAt;
    updatedAt = acct.updatedAt;
    username = acct.username;
    password = acct.password;
    extendField = acct.extendField;
  }
}

class EncryptAccount extends BaseAccount {
  String cipher = 'AES';
  AESMode mode = AESMode.cbc;
  String iv;
  String mKey;
  int encryptedAt;
  String data;

  EncryptAccount(super.name, this.iv, this.mKey, this.data, this.encryptedAt,
      {super.id, super.createdAt});

  EncryptAccount.fromJson(super.json)
      : cipher = json['cipher'],
        mode = AESMode.values.firstWhere((el) => el.name == json['mode']),
        iv = json['iv'],
        mKey = json['m_key'],
        encryptedAt = json['encrypted_at'],
        data = json['data'],
        super.fromJson();

  Map<String, dynamic> _toJson() => <String, dynamic>{
        'cipher': cipher,
        'mode': mode.name,
        'iv': iv,
        'encrypted_at': encryptedAt,
        'm_key': mKey,
        'data': data
      };

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json.addAll(_toJson());
    return json;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  PlainAccount decrypt(
    String pwd,
  ) {
    var key = keyFromPassword(pwd);

    var encrypter = Encrypter(AES(key, mode: mode));
    var decrypted = encrypter.decrypt64(
      data,
      iv: IV.fromBase64(iv),
    );
    var json = super.toJson();
    json.addAll(jsonDecode(decrypted));
    return PlainAccount.fromJson(json);
  }

  void assign(EncryptAccount acct) {
    id = acct.id;
    title = acct.title;
    groupID = acct.groupID;
    createdAt = acct.createdAt;
    updatedAt = acct.updatedAt;
    cipher = acct.cipher;
    mode = acct.mode;
    iv = acct.iv;
    mKey = acct.mKey;
    encryptedAt = acct.encryptedAt;
    data = acct.data;
  }
}

Key keyFromPassword(String password) {
  var pwdB = utf8.encode(password);
  var pwdSha = md5.convert(pwdB);
  pwdSha = md5.convert(pwdSha.bytes + pwdB);
  return Key(Uint8List.fromList(pwdSha.bytes));
}
