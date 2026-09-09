import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

class HiveService {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    await Hive.openBox(HiveBoxes.userBox);
    await Hive.openBox(HiveBoxes.productBox);
    await Hive.openBox(HiveBoxes.categoryBox);
    await Hive.openBox(HiveBoxes.bannerBox);
    await Hive.openBox(HiveBoxes.cartBox);
    await Hive.openBox(HiveBoxes.settingsBox);
  }

  static Box get userBox =>
      Hive.box(HiveBoxes.userBox);

  static Box get productBox =>
      Hive.box(HiveBoxes.productBox);

  static Box get categoryBox =>
      Hive.box(HiveBoxes.categoryBox);

  static Box get bannerBox =>
      Hive.box(HiveBoxes.bannerBox);

  static Box get cartBox =>
      Hive.box(HiveBoxes.cartBox);

  static Box get settingsBox =>
      Hive.box(HiveBoxes.settingsBox);

  static Future<void> saveSetting<T>(
    String key,
    T value,
  ) async {
    await settingsBox.put(
      key,
      value,
    );
  }

  static T getSetting<T>(
    String key, {
    required T defaultValue,
  }) {
    return settingsBox.get(
      key,
      defaultValue: defaultValue,
    ) as T;
  }

  static Future<void> clearAll() async {
    await userBox.clear();
    await productBox.clear();
    await categoryBox.clear();
    await bannerBox.clear();
    await cartBox.clear();
    await settingsBox.clear();
  }
}