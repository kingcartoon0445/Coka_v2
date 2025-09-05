import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/presentation/screens/auth/widget/loading_button.dart';

import '../../blocs/auth/auth_action_bloc.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _workplaceController = TextEditingController();
  String _selectedGender = 'Nam';
  final bool _isLoading = false;
  File? _selectedAvatar;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      context.read<AuthBloc>().add(LoadUserInfoRequested());
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Lỗi khi tải thông tin người dùng: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin người dùng')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      context.read<AuthBloc>().add(UpdateUserProfileRequested(
          fullName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          dob: _birthdayController.text,
          gender: _selectedGender,
          address: _workplaceController.text,
          avatar: _selectedAvatar));
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Lỗi khi tải thông tin người dùng: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin người dùng')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedAvatar = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('Lỗi chọn ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chọn ảnh, vui lòng thử lại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loadUserData && state.user != null) {
          setState(() {
            _nameController.text = state.user?.fullName ?? '';
            _emailController.text = state.user?.email ?? '';
            _phoneController.text = state.user?.phone ?? '';
            if (state.user?.dob != null) {
              final DateTime dob = state.user?.dob ?? DateTime.now();
              _birthdayController.text = "${dob.day}/${dob.month}/${dob.year}";
            }
            _workplaceController.text = state.user?.address ?? '';

            // Cập nhật avatar hiện tại
            _currentAvatarUrl = state.user?.avatar;

            // Cập nhật giới tính
            if (state.user?.gender != null) {
              switch (state.user?.gender) {
                case 0:
                  _selectedGender = 'Nữ';
                  break;
                case 1:
                  _selectedGender = 'Nam';
                  break;
                default:
                  _selectedGender = 'Khác';
                  break;
              }
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Cập nhật thông tin',
            style: TextStyles.heading1,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: _selectedAvatar != null
                                ? ClipOval(
                                    child: Image.file(
                                      _selectedAvatar!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _currentAvatarUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person_outline,
                                              size: 40,
                                              color: AppColors.text,
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const CircularProgressIndicator(
                                              strokeWidth: 2,
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_outline,
                                        size: 40,
                                        color: AppColors.text,
                                      ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 20,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên*',
                      hintText: 'Họ và tên',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email*',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthdayController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Ngày sinh',
                      hintText: 'DD/MM/YYYY',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giới Tính',
                    style: TextStyles.body,
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'Nam',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() => _selectedGender = value.toString());
                        },
                      ),
                      const Text('Nam'),
                      const SizedBox(width: 16),
                      Radio(
                        value: 'Nữ',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() => _selectedGender = value.toString());
                        },
                      ),
                      const Text('Nữ'),
                      const SizedBox(width: 16),
                      Radio(
                        value: 'Khác',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() => _selectedGender = value.toString());
                        },
                      ),
                      const Text('Khác'),
                    ],
                  ),
                  TextFormField(
                    controller: _workplaceController,
                    decoration: InputDecoration(
                      labelText: 'Nơi làm việc',
                      hintText: 'Chọn địa chỉ',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    text: 'Cập nhật',
                    onPressed: _updateProfile,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
