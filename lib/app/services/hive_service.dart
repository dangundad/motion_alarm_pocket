import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveService extends GetxService {
  static HiveService get to => Get.find<HiveService>();

  static const String settingsBox = 'motion_alarm_pocket_settings';
  static const String historyBox = 'motion_alarm_pocket_history';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(settingsBox),
      Hive.openBox<dynamic>(historyBox),
    ]);
  }

  Box<dynamic> get _settings => Hive.box<dynamic>(settingsBox);
  Box<dynamic> get _history => Hive.box<dynamic>(historyBox);

  T? getSetting<T>(String key) {
    final value = _settings.get(key);
    return value is T ? value : null;
  }

  Future<void> setSetting(String key, Object? value) async {
    await _settings.put(key, value);
  }

  List<Map<String, dynamic>> getHistory() {
    return _history.values
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList()
      ..sort((a, b) {
        final aTime = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
  }

  static const _maxHistoryEntries = 50;

  Future<void> addHistory(Map<String, dynamic> entry) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _history.put(id, {
      ...entry,
      'id': id,
      'createdAt': DateTime.now().toIso8601String(),
    });
    if (_history.length > _maxHistoryEntries) {
      final oldest = _history.keys.first;
      await _history.delete(oldest);
    }
  }

  Future<void> clearHistory() async {
    await _history.clear();
  }
}
