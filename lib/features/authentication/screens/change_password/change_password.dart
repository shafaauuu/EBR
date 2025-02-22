import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/size.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../controller/login_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>(); // Get the controller

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(Texts.changePasswordTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              title: Texts.currentPassword,
              hint: Texts.enterCurrentPassword,
              controller: loginController.currentPasswordController,
              isHidden: loginController.isPasswordHidden,
              toggleVisibility: loginController.togglePasswordVisibility,
            ),
            const SizedBox(height: Sizes.spaceBtwInputFields),
            _buildPasswordField(
              title: Texts.newPassword,
              hint: Texts.enterNewPassword,
              controller: loginController.newPasswordController,
              isHidden: loginController.isNewPasswordHidden,
              toggleVisibility: loginController.toggleNewPasswordVisibility,
            ),
            const SizedBox(height: Sizes.spaceBtwInputFields),
            _buildPasswordField(
              title: Texts.confirmNewPassword,
              hint: Texts.reenterNewPassword,
              controller: loginController.confirmPasswordController,
              isHidden: loginController.isConfirmPasswordHidden,
              toggleVisibility: loginController.toggleConfirmPasswordVisibility,
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {}, // Add your change password logic
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  Texts.changePasswordButton,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required RxBool isHidden,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller,
          obscureText: isHidden.value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            suffixIcon: IconButton(
              icon: Icon(isHidden.value ? Iconsax.eye_slash : Iconsax.eye),
              onPressed: toggleVisibility,
            ),
          ),
        )),
      ],
    );
  }
}
