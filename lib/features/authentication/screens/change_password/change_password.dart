import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/size.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../controller/login_controller.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0BEC5), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        Texts.changePasswordTitle,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: OColors.primary,
                          elevation: 3,
                        ),
                        icon: const Icon(Iconsax.key, color: Colors.white),
                        label: const Text(
                          Texts.changePasswordButton,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
            suffixIcon: IconButton(
              icon: Icon(isHidden.value ? Iconsax.eye_slash : Iconsax.eye),
              onPressed: toggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        )),
      ],
    );
  }
}
