import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oji_1/features/authentication/screens/home/home.dart';
import 'package:oji_1/features/authentication/screens/login/login.dart';
import 'package:oji_1/utils/constants/text_strings.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class LoginController extends GetxController {
  var rememberMe = true.obs;
  var isPasswordHidden = true.obs;
  final storage = GetStorage();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isNewPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

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

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  Future<void> signIn(BuildContext context) async {
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

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@(oneject\.com|oneject\.co\.id)$").hasMatch(email)) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.warning,
          title: "Invalid Email",
          text: "Please use an @oneject.com or @oneject.co.id email.",
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["token"] != null) {
        storage.write("auth_token", data["token"]); // Save token

        clearFields();
        fetchUserData();

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
      } else {
        String errorMessage;
        if (data["message"] == "User not found") { //not working
          errorMessage = "Email not registered.";
        } else if (data["message"] == "Incorrect password") { //not working
          errorMessage = "Password is incorrect.";
        } else {
          errorMessage = data["message"] ?? "Login failed. Please try again.";
        }

        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Login Failed",
            text: errorMessage,
          ),
        );
      }
    } catch (e) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Network Error",
          text: "Failed to connect to the server. Please try again.",
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    final token = storage.read("auth_token");

    if (token == null) {
      Get.offAll(() => const LoginScreen());
      return;
    }

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
          try {
            final response = await http.post(
              Uri.parse('http://127.0.0.1:8000/api/logout'),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            );

            if (response.statusCode == 200) {
              storage.erase(); // Clear all stored user data
              Get.offAll(() => const LoginScreen());
            } else {
              ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "Logout Failed",
                  text: "Failed to log out. Please try again.",
                ),
              );
            }
          } catch (e) {
            ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Network Error",
                text: "Failed to connect to the server.",
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> fetchUserData() async {
    final token = storage.read("auth_token");
    if (token == null) {
      print("No auth token found. User not logged in.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/user"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure these fields match the API response
        storage.write("user_email", data["email"]);
        storage.write("first_name", data["first_name"]);
        storage.write("last_name", data["last_name"]);
        storage.write("nik", data["nik"]);
        storage.write("divisi", data["div"]);
        storage.write("department", data["dept"]);
        storage.write("role", data["role"]);
        storage.write("inisial", data['inisial']);
        storage.write("group", data['group']);

        print("User data fetched successfully: $data");
      } else {
        print("Failed to fetch user data: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> changePassword(BuildContext context) async {
    final token = storage.read("auth_token");
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

    ///in progress
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/change-password'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "current_password": currentPassword,
          "new_password": newPassword,
          "confirm_password": confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
      } else {
        String errorMessage = data["message"] ?? "Failed to change password.";
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "Change Password Failed",
            text: errorMessage,
          ),
        );
      }
    } catch (e) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Network Error",
          text: "Failed to connect to the server.",
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
