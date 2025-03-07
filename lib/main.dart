import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'features/authentication/controller/login_controller.dart';
import 'features/authentication/controller/task_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final storage = GetStorage();
  String? token = storage.read("auth_token");

  Get.put(LoginController());
  Get.put(TaskController());

  runApp(MyApp(initialRoute: token == null ? '/login' : '/home'));
}


