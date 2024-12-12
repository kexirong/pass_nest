import 'package:get/get_utils/get_utils.dart';
import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import 'package:sqflite/sqflite.dart' as sqflite;


/// Sembast sqflite ffi based database factory.
/// Supports Windows/Linux/MacOS for now.
sqflite_ffi.DatabaseFactory get _defaultDatabaseFactory => (GetPlatform.isLinux || GetPlatform.isWindows)
    ? sqflite_ffi.databaseFactoryFfi
    : sqflite.databaseFactory;

DatabaseFactory get databaseFactory =>
    (GetPlatform.isWeb) ? databaseFactoryWeb : getDatabaseFactorySqflite(_defaultDatabaseFactory);
