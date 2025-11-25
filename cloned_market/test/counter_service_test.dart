import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloned_market/src/services/counter_service.dart';

void main() {
  group('CounterService Tests', () {
    late CounterService counterService;

    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      counterService = CounterService();
    });

    test('getCounter returns 0 when no value is stored', () async {
      SharedPreferences.setMockInitialValues({});
      await counterService.initialize();

      int value = await counterService.getCounter();

      expect(value, equals(0));
    });

    test('incrementCounter increments the value by 1', () async {
      SharedPreferences.setMockInitialValues({'counter_value': 5});
      counterService = CounterService();
      await counterService.initialize();

      int result = await counterService.incrementCounter();

      expect(result, equals(6));
    });

    test('incrementCounter increments from 0 when no previous value exists', ()
        async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      int result = await counterService.incrementCounter();

      expect(result, equals(1));
    });

    test('setCounter sets the counter to a specific value', () async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      await counterService.setCounter(42);
      int value = await counterService.getCounter();

      expect(value, equals(42));
    });

    test('resetCounter sets the counter back to 0', () async {
      SharedPreferences.setMockInitialValues({'counter_value': 100});
      counterService = CounterService();
      await counterService.initialize();

      await counterService.resetCounter();
      int value = await counterService.getCounter();

      expect(value, equals(0));
    });

    test('getCounter returns the correct stored value', () async {
      SharedPreferences.setMockInitialValues({'counter_value': 42});
      counterService = CounterService();
      await counterService.initialize();

      int value = await counterService.getCounter();

      expect(value, equals(42));
    });

    test('multiple increments work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      await counterService.incrementCounter();
      await counterService.incrementCounter();
      int result = await counterService.incrementCounter();

      expect(result, equals(3));
    });

    test('getPrefsInstance returns the SharedPreferences instance', () async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      var prefs = counterService.getPrefsInstance();

      expect(prefs, isNotNull);
      expect(prefs is SharedPreferences, isTrue);
    });

    test('isFirstLaunch returns true when welcome dialog has not been seen',
        () async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      bool isFirst = await counterService.isFirstLaunch();

      expect(isFirst, isTrue);
    });

    test('isFirstLaunch returns false after markWelcomeDismissed is called',
        () async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      await counterService.markWelcomeDismissed();
      bool isFirst = await counterService.isFirstLaunch();

      expect(isFirst, isFalse);
    });

    test(
        'isFirstLaunch persists across instances when welcome dialog has been dismissed',
        () async {
      SharedPreferences.setMockInitialValues({});
      counterService = CounterService();
      await counterService.initialize();

      // Mark welcome as dismissed
      await counterService.markWelcomeDismissed();

      // Create a new instance and verify the flag persists
      counterService = CounterService();
      await counterService.initialize();
      bool isFirst = await counterService.isFirstLaunch();

      expect(isFirst, isFalse);
    });
  });
}
