import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_market_clone/src/pages/root_controller.dart';
import 'package:my_market_clone/src/pages/home/home_page.dart';
import 'package:my_market_clone/src/pages/neighborhood/neighborhood_page.dart';
import 'package:my_market_clone/src/pages/nearby/nearby_page.dart';
import 'package:my_market_clone/src/pages/chat/chat_page.dart';
import 'package:my_market_clone/src/pages/mypage/my_page.dart';

class RootPage extends GetView<RootController> {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RootController());
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomePage(),
            NeighborhoodPage(),
            NearbyPage(),
            ChatPage(),
            MyPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          backgroundColor: const Color(0xff212123),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            _buildNavItem('홈', 'home'),
            _buildNavItem('동네생활', 'arround-life'),
            _buildNavItem('내 근처', 'near'),
            _buildNavItem('채팅', 'chat'),
            _buildNavItem('나의 밤톨', 'my'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String label, String iconName) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/svg/icons/$iconName-off.svg',
        width: 24,
        height: 24,
      ),
      activeIcon: SvgPicture.asset(
        'assets/svg/icons/$iconName-on.svg',
        width: 24,
        height: 24,
      ),
      label: label,
    );
  }
}
