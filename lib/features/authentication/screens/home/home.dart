import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oji_1/features/authentication/controller/login_controller.dart';
import 'package:oji_1/features/authentication/screens/tabs/ongoing.dart';
import 'package:oji_1/features/authentication/screens/tabs/pending.dart';
import 'package:oji_1/features/authentication/screens/tabs/completed.dart';
import 'package:oji_1/features/authentication/screens/profile/profile.dart';
import '../../../../utils/constants/text_strings.dart';
import '../change_password/change_password.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final loginController = Get.find<LoginController>(); // Using Controller

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
                  Get.to(() => const ChangePasswordPage());
                } else if (value == 'logout') {
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
                        user?.email ?? 'user@example.com',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text("Production Operation"),
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
