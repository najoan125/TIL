import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_market_clone/src/pages/splash_page.dart';
import 'package:my_market_clone/src/pages/intro_page.dart';
import 'package:my_market_clone/src/pages/root_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '당근마켓 클론코딩',
      initialRoute: '/',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xff212123),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xff212123),
      ),
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/intro', page: () => const IntroPage()),
        GetPage(name: '/home', page: () => const RootPage()),
      ],
    );
  }
}
