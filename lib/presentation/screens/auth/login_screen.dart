// lib/pages/auth/login_screen.dart

import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/config/routes.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/generated/assets.gen.dart';
import 'package:source_base/presentation/screens/auth/verify_otp_page.dart';
import 'package:source_base/presentation/screens/auth/widget/loading_button.dart';
import 'package:source_base/presentation/widget/language_switcher.dart';

import '../../blocs/auth/auth_action_bloc.dart';
import '../../blocs/organization/organization_action_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String baseUrl = DioClient.baseUrl;
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<AuthBloc>()
        .add(LoginRequested(email: emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthBloc>().add(CheckAuthStatus());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.read<OrganizationBloc>().add(ChangeOrganization(
                organizationId: state.organizationId!,
              ));
          context.go(state.initialLocation ?? '/');
        }
        if (state.status == AuthStatus.confirmAccount &&
            state.organizationId != null) {
          context.go('/organization/${state.organizationId}');
        }

        if (state.status == AuthStatus.emailDone && state.otpId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyOtpScreen(
                email: state.email!,
                otpId: state.otpId!,
              ),
            ),
          );
        }
        if (state.status == AuthStatus.confirmAccount) {
          context.go(AppPaths.completeProfile);
        }
        if (state.status == AuthStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/organization/default');
          // context.go(AppPaths.organization());
        }
        if (state.status == AuthStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const LanguageDropdown(),
                    const SizedBox(height: 20),
                    // 👇 Popup menu debug chọn baseURL
                    PopupMenuButton<String>(
                        enabled: kDebugMode,
                        color: Colors.white,
                        onSelected: (value) async {
                          await DioClient().setBaseUrl(value);
                          setState(() {
                            baseUrl = value;
                          });
                        },
                        itemBuilder: (context) {
                          return [
                            DioClient.baseUrlCoka,
                            DioClient.baseUrlDev,
                            DioClient.baseUrl
                          ].map((base) {
                            return PopupMenuItem<String>(
                              value: base,
                              child: Row(
                                children: [
                                  Icon(
                                    base == baseUrl
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: base == baseUrl
                                        ? Colors.blueAccent
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      base,
                                      style: TextStyle(
                                        fontWeight: base == baseUrl
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: base == baseUrl
                                            ? Colors.blueAccent
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Assets.images.cokaLogin.image(height: 80)),
                    const SizedBox(height: 12),
                    Text('login'.tr(), style: TextStyles.heading1),
                    const SizedBox(height: 8),
                    Text('welcome_text'.tr(), style: TextStyles.body),
                    const SizedBox(height: 28),

                    // Input Email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyles.label,
                            children: [
                              TextSpan(text: "${'form_email'.tr()} "),
                              const TextSpan(
                                  text: '*',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'input_email'.tr(),
                            filled: true,
                            fillColor: AppColors.backgroundSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    LoadingButton(
                      text: 'login'.tr(),
                      onPressed: () => _handleSubmit(context),
                      isLoading: state.status == AuthStatus.loading,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'or_login_with'.tr(),
                            style: TextStyles.body
                                .copyWith(color: Colors.grey.shade700),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSocialButton(
                      context,
                      'google_icon.png',
                      'Google',
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(LoginWithGoogleRequested()),
                      isLoading: state.status == AuthStatus.loading,
                    ),
                    const SizedBox(height: 14),
                    _buildSocialButton(
                      context,
                      'facebook_icon.png',
                      'Facebook',
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(LoginWithFacebookRequested()),
                      isLoading: state.status == AuthStatus.loading,
                    ),
                    const SizedBox(height: 14),
                    if (Platform.isIOS)
                      _buildSocialButton(context, 'apple_icon.png', 'Apple'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String iconName,
    String label, {
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return FilledButton.tonal(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            '${AppConstants.imagePath}/$iconName',
            height: 24,
            width: 24,
          ),
          Expanded(
            child: Text(
              '${'login_with'.tr()} $label',
              style: TextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
