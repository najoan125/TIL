import 'package:shared_preferences/shared_preferences.dart';

class CounterService {
  static const String _counterKey = 'counter_value';
  static const String _firstLaunchKey = 'has_seen_welcome_dialog';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<int> getCounter() async {
    return _prefs.getInt(_counterKey) ?? 0;
  }

  Future<int> incrementCounter() async {
    int currentValue = _prefs.getInt(_counterKey) ?? 0;
    int newValue = currentValue + 1;
    await _prefs.setInt(_counterKey, newValue);
    return newValue;
  }

  Future<void> setCounter(int value) async {
    await _prefs.setInt(_counterKey, value);
  }

  Future<void> resetCounter() async {
    await _prefs.setInt(_counterKey, 0);
  }

  Future<bool> isFirstLaunch() async {
    return !(_prefs.getBool(_firstLaunchKey) ?? false);
  }

  Future<void> markWelcomeDismissed() async {
    await _prefs.setBool(_firstLaunchKey, true);
  }

  SharedPreferences getPrefsInstance() {
    return _prefs;
  }
}
