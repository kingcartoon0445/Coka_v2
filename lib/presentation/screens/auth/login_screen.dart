// lib/pages/auth/login_screen.dart (refactored)

import 'dart:io' show Platform; // Guarded by !kIsWeb when used

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String _baseUrl = DioClient.baseUrl;

  @override
  void initState() {
    super.initState();
    // ✅ Avoid side-effects in build: check auth once here
    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  Future<void> _handleSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      _emailFocus.requestFocus();
      return;
    }
    context
        .read<AuthBloc>()
        .add(LoginRequested(email: _emailController.text.trim()));
  }

  bool get _showAppleButton => !kIsWeb && Platform.isIOS; // Safe on web

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            if (state.organizationId != null) {
              context.read<OrganizationBloc>().add(
                  ChangeOrganization(organizationId: state.organizationId!));
            }
            context.go(state.initialLocation ?? '/');
            break;

          case AuthStatus.confirmAccount:
            if (state.organizationId != null) {
              context.go('/organization/${state.organizationId}');
            } else {
              context.go(AppPaths.completeProfile);
            }
            break;

          case AuthStatus.emailDone:
            if (state.otpId != null && state.email != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      VerifyOtpScreen(email: state.email!, otpId: state.otpId!),
                ),
              );
            }
            break;

          case AuthStatus.success:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Đăng nhập thành công'),
                  backgroundColor: AppColors.success),
            );
            context.read<OrganizationBloc>().add(const LoadOrganizations(
                  limit: '10',
                  offset: '0',
                  searchText: '',
                ));
            context.go('/organization/default');
            break;

          case AuthStatus.error:
            final msg = state.error?.trim();
            if (msg != null && msg.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            break;

          case AuthStatus.initial:
          case AuthStatus.loading:
          case AuthStatus.unauthenticated:
          default:
            break;
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 24, left: 16, right: 16, bottom: 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const LanguageDropdown(),
                      const SizedBox(height: 20),

                      // 👇 Debug baseURL picker (hidden in release)
                      if (kDebugMode)
                        PopupMenuButton<String>(
                          color: Colors.white,
                          onSelected: (value) async {
                            await DioClient().setBaseUrl(value);
                            setState(() => _baseUrl = value);
                          },
                          itemBuilder: (context) {
                            final bases = <String>[
                              DioClient.baseUrlCoka,
                              DioClient.baseUrlDev,
                              DioClient.baseUrl
                            ];
                            return bases.map((base) {
                              final selected = base == _baseUrl;
                              return PopupMenuItem<String>(
                                value: base,
                                child: Row(
                                  children: [
                                    Icon(
                                        selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: selected
                                            ? Colors.blueAccent
                                            : Colors.grey,
                                        size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        base,
                                        style: TextStyle(
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
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
                          child: Assets.images.cokaLogin.image(height: 80),
                        )
                      else
                        Assets.images.cokaLogin.image(height: 80),

                      const SizedBox(height: 12),
                      Text('login'.tr(),
                          style: TextStyles.heading1,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('welcome_text'.tr(),
                          style: TextStyles.body, textAlign: TextAlign.center),
                      const SizedBox(height: 28),

                      // Email input
                      Text.rich(
                        TextSpan(
                          style: TextStyles.label,
                          children: [
                            TextSpan(text: "${'form_email'.tr()} "),
                            const TextSpan(
                                text: '*',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        decoration: InputDecoration(
                          hintText: 'input_email'.tr(),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
                        onFieldSubmitted: (_) => _handleSubmit(),
                        validator: _validateEmail,
                        enabled: !isLoading,
                      ),

                      const SizedBox(height: 16),
                      LoadingButton(
                        text: 'login'.tr(),
                        onPressed: _handleSubmit,
                        isLoading: isLoading,
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
                            child: Text('or_login_with'.tr(),
                                style: TextStyles.body
                                    .copyWith(color: Colors.grey.shade700)),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SocialLoginButton(
                        iconAssetName: 'google_icon.png',
                        label: 'Google',
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(LoginWithGoogleRequested()),
                      ),
                      const SizedBox(height: 14),
                      SocialLoginButton(
                        iconAssetName: 'facebook_icon.png',
                        label: 'Facebook',
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(LoginWithFacebookRequested()),
                      ),
                      const SizedBox(height: 14),
                      if (_showAppleButton)
                        SocialLoginButton(
                          iconAssetName: 'apple_icon.png',
                          label: 'Apple',
                          onPressed: isLoading ? null : () {},
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.iconAssetName,
    required this.label,
    this.onPressed,
  });

  final String iconAssetName;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
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
          Image.asset('${AppConstants.imagePath}/$iconAssetName',
              height: 24, width: 24),
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
