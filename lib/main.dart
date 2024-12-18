import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'services/webdav/sync_webdav.dart';
import 'services/accounts_service.dart';
import 'services/db/data_provider.dart';
import 'services/groups_service.dart';
import 'services/config_service.dart';

import 'routes/app_pages.dart';
import 'theme.dart';

void main() async {
  const themes = MaterialTheme4();
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: themes.light(),
      darkTheme: themes.dark(),
      highContrastTheme: themes.lightMediumContrast(),
      highContrastDarkTheme: themes.darkMediumContrast(),
      initialBinding: BindingsBuilder(
        () {
          if (kDebugMode) {
            print('starting lazyPut ...');
          }
          Get.put(AccountsService());
          Get.put(GroupsService());
          Get.put(SyncWebdavService());

          if (kDebugMode) {
            print('All lazyPut started...');
          }
        },
      ),
    ),
  );
}

Future initServices() async {
  if (kDebugMode) {
    print('starting services ...');
  }
  await Get.putAsync(() => DataProviderService().init());
  await Get.put(ConfigService()).init();
  if (kDebugMode) {
    print('All services started...');
  }
}
