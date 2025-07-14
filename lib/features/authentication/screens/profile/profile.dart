import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controller/login_controller.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/size.dart';
import '../change_password/change_password.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final email = storage.read("user_email") ?? "user@oneject.co.id";
    final firstName = storage.read("first_name") ?? "First Name";
    final lastName = storage.read("last_name") ?? "Last Name";
    final nik = storage.read("nik")?.toString() ?? "-";
    final divisi = storage.read("divisi") ?? "-";
    final department = storage.read("department") ?? "-";
    final role = storage.read("role") ?? "-";
    final inisial = storage.read("inisial") ?? "-";
    final group = storage.read("group") ?? "-";

    final loginController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: OColors.lightGrey,
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: OColors.darkerGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    "$firstName $lastName",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: OColors.darkerGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwInputFields),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    profileDetail("NIK", nik),
                    profileDetail("Divisi", divisi),
                    profileDetail("Department", department),
                    profileDetail("Role", role),
                    profileDetail("Inisial", inisial),
                    profileDetail("Group", group),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwInputFields),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Get.to(() => const ChangePassword());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => loginController.logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileDetail(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(value),
        const Divider(),
      ],
    );
  }
}
