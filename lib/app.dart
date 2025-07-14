import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/screens/home/home.dart';
import 'package:oji_1/features/authentication/screens/login/login.dart';
import 'package:oji_1/utils/theme/theme.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oneject',
      themeMode: ThemeMode.system,
      theme: OAppTheme.lightTheme,
      darkTheme: OAppTheme.lightTheme,
      initialRoute: initialRoute, // Use the initialRoute
      getPages: [
        GetPage(name: '/', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}

