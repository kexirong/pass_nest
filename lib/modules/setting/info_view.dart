import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/db/data_provider.dart';

class Controller extends GetxController {
  var count = 0.obs;
  var lists = [1, 2, 3, 4].obs;

  increment() => count++;

  add() => lists.add(count.value);

  pop() => lists.removeLast();
}

class SettingInfo extends StatelessWidget {
  const SettingInfo({super.key});

  @override
  Widget build(context) {
    // 使用Get.put()实例化你的类，使其对当下的所有子路由可用。
    final Controller c = Get.put(Controller());
    ever(c.lists, (v) {
      print(v);
    });

    return Scaffold(
        // 使用Obx(()=>每当改变计数时，就更新Text()。
        appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),

        // 用一个简单的Get.to()即可代替Navigator.push那8行，无需上下文！
        body: Center(
            child: Column(
          children: [
            ElevatedButton(child: const Text("add"), onPressed: () => c.add()),
            ElevatedButton(child: const Text("pop"), onPressed: () => c.pop()),
            ElevatedButton(
                child: const Text("show"),
                onPressed: () async {
                  DataProviderService dps = Get.find();
                  print(await dps.getChangeRecords());
                }),
          ],
        )),
        floatingActionButton:
            FloatingActionButton(onPressed: c.increment, child: const Icon(Icons.add)));
  }
}
