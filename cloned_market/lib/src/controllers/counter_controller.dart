import 'package:get/get.dart';
import '../services/counter_service.dart';

class CounterController extends GetxController {
  final CounterService _counterService = CounterService();
  final RxInt counter = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isFirstLaunch = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCounter();
  }

  Future<void> _initializeCounter() async {
    try {
      isLoading.value = true;
      await _counterService.initialize();
      int savedValue = await _counterService.getCounter();
      counter.value = savedValue;

      // Check if this is the first launch
      bool firstLaunch = await _counterService.isFirstLaunch();
      isFirstLaunch.value = firstLaunch;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> incrementCounter() async {
    int newValue = await _counterService.incrementCounter();
    counter.value = newValue;
  }

  Future<void> resetCounter() async {
    await _counterService.resetCounter();
    counter.value = 0;
  }

  Future<void> dismissWelcomeDialog() async {
    await _counterService.markWelcomeDismissed();
    isFirstLaunch.value = false;
  }
}
