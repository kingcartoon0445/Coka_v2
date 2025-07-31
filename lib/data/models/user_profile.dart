// lib/models/user_profile.dart

import 'dart:convert';

class UserProfile {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? email;
  final DateTime? dob;
  final int? gender;
  final String? about;
  final String? address;
  final String? position;
  final String? avatar;
  final String? cover;
  final bool? isVerifyPhone;
  final bool? isVerifyEmail;
  final bool isFcm;

  UserProfile({
    this.id,
    this.fullName,
    this.phone,
    this.email,
    this.dob,
    this.gender,
    this.about,
    this.address,
    this.position,
    this.avatar,
    this.cover,
    this.isVerifyPhone,
    this.isVerifyEmail,
    required this.isFcm,
  });

  /// Tạo từ Map (ví dụ khi decode JSON)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
      email: json['email'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'],
      about: json['about'],
      address: json['address'],
      position: json['position'],
      avatar: json['avatar'],
      cover: json['cover'],
      isVerifyPhone: json['isVerifyPhone'],
      isVerifyEmail: json['isVerifyEmail'],
      isFcm: json['isFcm'],
    );
  }

  /// Chuyển ngược lại thành Map (để encode ra JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'about': about,
      'address': address,
      'position': position,
      'avatar': avatar,
      'cover': cover,
      'isVerifyPhone': isVerifyPhone,
      'isVerifyEmail': isVerifyEmail,
      'isFcm': isFcm,
    };
  }

  /// Nếu bạn có JSON string, dùng:
  static UserProfile fromJsonString(String jsonString) =>
      UserProfile.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  /// Và ngược lại:
  String toJsonString() => json.encode(toJson());
}
