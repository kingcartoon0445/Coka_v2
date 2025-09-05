 import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/presentation/screens/auth/widget/loading_button.dart';

import '../../blocs/auth/auth_action_bloc.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String otpId;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.otpId,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpScreen> {
  final otpController = TextEditingController();
  bool isLoading = false;
  Future<void> _verifyOtp() async {
    try {
      context.read<AuthBloc>().add(SendVerifyOtpRequested(
            otpId: widget.otpId.trim(),
            otpCode: otpController.text.trim(),
          ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết nối tới server'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    try {
      context
          .read<AuthBloc>()
          .add(ReSendOtpRequested(otpId: widget.otpId.trim()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết nối tới server'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
          if (state.status == AuthStatus.sentOTPDone) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã gửi lại mã OTP'),
                backgroundColor: AppColors.success,
              ),
            );
            // Xử lý khi xác thực OTP thành công
          }
        }, builder: (context, state) {
          return _buildBody(state);
        }),
      ),
    );
  }

  _buildBody(AuthState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Image.asset(
            '${AppConstants.imagePath}/verify_icon.png',
            height: 80,
          ),
          const SizedBox(height: 14),
          Text(
            'login_with_email'.tr(),
            style: TextStyles.heading1,
          ),
          const SizedBox(height: 6),
          Text(
            'check_mail'.tr(),
            style: TextStyles.title.copyWith(
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: otpController,
            autoFocus: true,
            keyboardType: TextInputType.number,
            cursorColor: AppColors.primary,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 50,
              fieldWidth: 45,
              activeFillColor: AppColors.backgroundSecondary,
              selectedFillColor: AppColors.backgroundSecondary,
              inactiveFillColor: AppColors.backgroundSecondary,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
              selectedColor: AppColors.primary,
              borderWidth: 1,
            ),
            enableActiveFill: true,
            onCompleted: (value) {
              if (!isLoading) {
                _verifyOtp();
              }
            },
            onChanged: (value) {},
            boxShadows: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LoadingButton(
            text: 'next'.tr(),
            onPressed: _verifyOtp,
            isLoading: state.status == AuthStatus.loading,
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _resendOtp,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'not_receive_mail'.tr(),
                    style: TextStyles.body.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  TextSpan(
                    text: 'resend_mail'.tr(),
                    style: TextStyles.body.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              // Xử lý quay lại trang đăng nhập
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: AppColors.text,
                ),
                const SizedBox(width: 4),
                Text(
                  'back_to_login'.tr(),
                  style: TextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
