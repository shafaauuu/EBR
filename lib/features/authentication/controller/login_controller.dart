import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:oji_1/features/authentication/screens/home/home.dart';
import '../../../utils/constants/text_strings.dart';
import '../screens/login/login.dart';

class LoginController extends GetxController {
  var rememberMe = true.obs;
  var isPasswordHidden = true.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isNewPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void showForgotPasswordAlert(BuildContext context) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.info,
        title: Texts.forgetPassword,
        text: "Please contact the IT team for password recovery.",
        confirmButtonText: "OK",
      ),
    );
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void logout(BuildContext context) async {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.warning,
        title: Texts.logoutConfirmationTitle,
        text: Texts.logoutConfirmationMessage,
        showCancelBtn: true,
        cancelButtonText: Texts.logoutCancel,
        confirmButtonText: Texts.logoutButton,
        onConfirm: () async {
          await FirebaseAuth.instance.signOut();
          Get.find<LoginController>().clearFields();
          Get.offAll(() => const LoginScreen());

          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: Texts.loggedOutTitle,
              text: Texts.loggedOutMessage,
            ),
          );
        },
      ),
    );
  }

  // Change Password Function
  Future<void> changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "All fields are required!",
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.warning,
          title: "Password Mismatch",
          text: "New passwords do not match!",
        ),
      );
      return;
    }

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Success",
          text: "Password changed successfully!",
        ),
      );

      clearFields();
      Get.offAll(() => const HomePage());

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "wrong-password":
          errorMessage = "Current password is incorrect.";
          break;
        case "weak-password":
          errorMessage = "New password is too weak.";
          break;
        case "requires-recent-login":
          errorMessage = "Please log in again to change your password.";
          break;
        default:
          errorMessage = "Failed to change password. Please try again.";
      }

      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Change Password Failed",
          text: errorMessage,
        ),
      );
    }
  }

  // Login Function
  void signIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Error",
          text: "Email and password cannot be empty!",
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: Texts.loginSuccessTitle,
          text: Texts.loginSuccessMessage,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => const HomePage());
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "network-request-failed":
          errorMessage = "Network error. Please check your connection.";
          break;
        case "too-many-requests":
          errorMessage = "Too many login attempts. Try again later.";
          break;
        case "invalid-email":
          errorMessage = "Invalid email format.";
          break;
        case "wrong-password":
          errorMessage = "Incorrect password.";
          break;
        case "user-not-found":
          errorMessage = "No user found with this email.";
          break;
        default:
          errorMessage = 'Wrong email/password. Please try again.';
      }

      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: Texts.loginFailedTitle,
          text: errorMessage,
        ),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
