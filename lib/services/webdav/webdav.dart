import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as p;

class WebdavClient {
  final webdav.Client _client;

  String rootPath = '';
  bool _isClose = false;

  bool get isClose => _isClose;

  WebdavClient(
    String url,
    String user,
    String password, {
    String path = '',
    debug = false,
  })  : _client = webdav.newClient(
          url,
          user: user,
          password: password,
          debug: debug,
        ),
        rootPath = p.join('/', path) {
    _client.setHeaders({'accept-charset': 'utf-8'});
    _client.setHeaders({'content-type': 'text/html'});
    _client.setConnectTimeout(30000);
    _client.setSendTimeout(5000);
    _client.setReceiveTimeout(5000);
  }

  Future<List<String>> list({String? prefix, String? path}) async {
    path ??= rootPath;
    var result = <String>[];
    var data = await _client.readDir(path);
    for (var i in data) {
      if (i.name == null || (prefix != null && !prefix.startsWith(i.name!))) {
        continue;
      }
      result.add(i.name!);
    }
    return result;
  }

  Future<String?> read(String name, {String? path}) async {
    path ??= rootPath;
    var fPath = p.join(path, name);
    try {
      var bytes = await _client.read(fPath);
      return String.fromCharCodes(bytes);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        rethrow;
      }
      return null;
    }
  }

  Future<void> write(String name, String data, {String? path}) async {
    path ??= rootPath;
    var fPath = p.join(path, name);
    await _client.write(fPath, Uint8List.fromList(data.codeUnits));
  }

  Future<void> delete(String name, {String? path}) async {
    path ??= rootPath;
    var fPath = p.join(path, name);
    return await _client.removeAll(fPath);
  }

  void close() {
    _isClose = true;
  }

  Future<bool> ping() async {
    try {
      await _client.ping();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  webdav.Client get client => _client;
}
