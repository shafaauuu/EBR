import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:oji_1/common/styles/spacing_styles.dart';
import 'package:oji_1/utils/constants/colors.dart';
import 'package:oji_1/utils/constants/size.dart';
import 'package:oji_1/utils/constants/text_strings.dart';
import 'package:oji_1/utils/helpers/helper_functions.dart';
import '../../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = OHelperFunction.isDarkMode(context);
    final loginController = Get.put(LoginController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: OSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and Titles
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    height: 150,
                    image: const AssetImage('assets/logos/Oneject-removebg-preview.png'),
                  ),
                  const SizedBox(height: Sizes.sm),
                  Text(
                    Texts.loginTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),

              // Login Form
              Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sizes.spaceBtwSections),
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: loginController.emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.direct_right),
                          labelText: Texts.email,
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields),

                      // Password Field with Eye Icon
                      Obx(() => TextFormField(
                        controller: loginController.passwordController,
                        obscureText: loginController.isPasswordHidden.value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.password_check),
                          labelText: Texts.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              loginController.isPasswordHidden.value ? Iconsax.eye_slash : Iconsax.eye,
                            ),
                            onPressed: loginController.togglePasswordVisibility,
                          ),
                        ),
                      )),
                      const SizedBox(height: Sizes.spaceBtwInputFields / 2),

                      // Remember Me and Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Obx(() => Checkbox(
                              //   value: loginController.rememberMe.value,
                              //   onChanged: loginController.toggleRememberMe,
                              // )),
                              // const Text(Texts.rememberMe),
                            ],
                          ),
                          TextButton(
                            onPressed: () => loginController.showForgotPasswordAlert(context),
                            child: const Text(Texts.forgetPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields),

                      // Log In Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => loginController.signIn(context),
                          child: const Text(Texts.signIn),
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),
                    ],
                  ),
                ),
              ),


              // Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Divider(
                      color: dark ? OColors.darkGrey : OColors.darkerGrey,
                      thickness: 0.5,
                      indent: 60,
                      endIndent: 5,
                    ),
                  ),
                  Text(Texts.oneject, style: Theme.of(context).textTheme.labelMedium),
                  Flexible(
                    child: Divider(
                      color: dark ? OColors.darkerGrey : OColors.darkerGrey,
                      thickness: 0.5,
                      indent: 5,
                      endIndent: 60,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
