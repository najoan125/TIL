import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SplashStatus {
  dataLoad('데이터 로드 중...'),
  authCheck('인증 체크 중...');

  final String message;
  const SplashStatus(this.message);
}

class SplashController extends GetxController {
  final status = SplashStatus.dataLoad.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    // 데이터 로드
    status.value = SplashStatus.dataLoad;
    await Future.delayed(const Duration(seconds: 1));

    // 인증 체크
    status.value = SplashStatus.authCheck;
    await Future.delayed(const Duration(seconds: 1));

    // 최초 실행 여부 확인 후 분기
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      Get.offNamed('/intro');
    } else {
      Get.offNamed('/home');
    }
  }
}
