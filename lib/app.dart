import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oji_1/features/authentication/screens/login/login.dart';
import 'package:oji_1/utils/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oneject',
      themeMode: ThemeMode.system,
      theme: OAppTheme.lightTheme,
      darkTheme: OAppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
