import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/constants/text_strings.dart';
import '../../controller/login_controller.dart';
import '../../controller/task_controller.dart';
import '../change_password/change_password.dart';
import '../profile/profile.dart';
import '../tabs/completed.dart';
import '../tabs/ongoing.dart';
import '../tabs/pending.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please rotate your device to landscape mode.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final storage = GetStorage();
    final firstName = storage.read("first_name") ?? "First Name";
    final department = storage.read("department") ?? "No Department";
    final role = storage.read("role") ?? "No Role";
    final TaskController taskController = Get.put(TaskController());


    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/logos/Oneject-removebg-preview.png',
                height: 40,
              ),
              const SizedBox(width: 10),
              const Text(Texts.appTitle),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, size: 34),
              offset: const Offset(0, 40),
              onSelected: (String value) {
                if (value == 'profile') {
                  Get.to(() => const ProfilePage());
                } else if (value == 'change_password') {
                  Get.to(() => const ChangePassword());
                } else if (value == 'logout') {
                  final loginController = Get.find<AuthController>();
                  loginController.logout(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        department,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        role,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Text(Texts.profile),
                ),
                const PopupMenuItem<String>(
                  value: 'change_password',
                  child: Text(Texts.changePasswordTitle),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text(Texts.logout),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: Texts.ongoingTab),
              Tab(text: Texts.pendingTab),
              Tab(text: Texts.completedTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OngoingPage(),
            PendingPage(),
            CompletedPage(),
          ],
        ),
      ),
    );
  }
}
