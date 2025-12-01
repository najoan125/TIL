import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_market_clone/src/pages/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_simbol.png'),
            const SizedBox(height: 24),
            Obx(() => Text(
                  controller.status.value.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
