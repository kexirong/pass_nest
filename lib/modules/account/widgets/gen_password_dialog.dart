import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GenPasswordDialog extends StatelessWidget {
  const GenPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: GenPasswordController(),
      builder: (controller) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
        actionsPadding: const EdgeInsets.only(right: 24),
        title: Text.rich(
          TextSpan(
            text: '生成随机密码',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '[${controller.slider.truncate()}]',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              )
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(controller.password),
            Slider(
              value: controller.slider,
              max: 32.0,
              min: 6.0,
              onChanged: (double val) {
                controller.setSlider(val.roundToDouble());
              },
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: controller.capital,
                  onChanged: (bool? value) {
                    controller.setCapital(value!);
                  },
                ),
                const Text("包含大写字母"),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: controller.lowercase,
                  onChanged: (bool? value) {
                    controller.setLowercase(value!);
                  },
                ),
                const Text("包含小写字母"),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: controller.punctuation,
                  onChanged: (bool? value) {
                    controller.setPunctuation(value!);
                  },
                ),
                const Text("包含特殊符号"),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("取消"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("刷新"),
            onPressed: () {},
          ),
          TextButton(
            child: const Text("复制密码"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: controller.password));
              Get.rawSnackbar(message: '已复制到剪贴板!');
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

class GenPasswordController extends GetxController {
  double _slider = 8;

  double get slider => _slider;

  void setSlider(double v) {
    _slider = v;
    update();
  }

  bool _capital = true;

  bool get capital => _capital;

  void setCapital(bool v) {
    _capital = v;
    update();
  }

  bool _lowercase = true;

  bool get lowercase => _lowercase;

  void setLowercase(bool v) {
    _lowercase = v;
    update();
  }

  bool _punctuation = false;

  bool get punctuation => _punctuation;

  void setPunctuation(bool v) {
    _punctuation = v;
    update();
  }

  String get password {
    String chars = '01234567890123456789';
    if (capital) {
      chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    }
    if (lowercase) {
      chars += 'abcdefghijklmnopqrstuvwxyz';
    }
    if (punctuation) {
      chars += '!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';
    }
    var rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(_slider.truncate(), (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
