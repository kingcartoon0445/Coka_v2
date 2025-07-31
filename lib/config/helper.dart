import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';

class Helpers {
  /// Kiểm tra xem response có thành công hay không
  /// Hỗ trợ các mã: 0 (success), 200 (OK), 201 (Created)
  static bool isResponseSuccess(Map<String, dynamic>? response) {
    if (response == null) return false;
    if (response['StatusCode'] == 200) return true;
    final code = response['code'];
    return code == 0 || code == 200 || code == 201;
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  static String formatDate(DateTime date) {
    // Logic format date
    return '';
  }

  /// Chuyển đổi ngày từ định dạng dd/MM/yyyy sang ISO string
  static String convertToISOString(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final date = DateTime(
        int.parse(parts[2]), // năm
        int.parse(parts[1]), // tháng
        int.parse(parts[0]), // ngày
      );
      return date.toIso8601String();
    }
    return dateStr;
  }

  static String getAvatarUrl(String? imgData) {
    if (imgData == null || imgData.isEmpty) return '';
    if (imgData.contains('https')) return imgData;
    return '${DioClient.baseUrl}$imgData';
  }

  /// Clear cache cho một URL cụ thể
  static Future<void> clearImageCache(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    final url = getAvatarUrl(imageUrl);
    await CachedNetworkImage.evictFromCache(url);
  }

  /// Clear toàn bộ image cache
  static Future<void> clearAllImageCache() async {
    await DefaultCacheManager().emptyCache();
  }

  static Color getColorFromText(String text) {
    final List<Color> colors = [
      const Color(0xFF1E88E5), // Blue
      const Color(0xFFE53935), // Red
      const Color(0xFF43A047), // Green
      const Color(0xFF8E24AA), // Purple
      const Color(0xFFFFB300), // Amber
      const Color(0xFF00897B), // Teal
      const Color(0xFF3949AB), // Indigo
      const Color(0xFFD81B60), // Pink
      const Color(0xFF6D4C41), // Brown
      const Color(0xFF546E7A), // Blue Grey
    ];

    // Tính tổng mã ASCII của các ký tự trong text
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      sum += text.codeUnitAt(i);
    }

    // Lấy màu dựa trên phần dư của tổng với số lượng màu
    return colors[sum % colors.length];
  }

  static Color getTabBadgeColor(String tabName) {
    switch (tabName) {
      case "Tất cả":
        return const Color(0xFF5C33F0);
      case "Tiềm năng":
        return const Color(0xFF92F7A8);
      case "Giao dịch":
        return const Color(0xFFA4F3FF);
      case "Không tiềm năng":
        return const Color(0xFFFEC067);
      case "Chưa xác định":
        return const Color(0xFF9F87FF);
      default:
        return const Color(0xFF9F87FF);
    }
  }

  static String? getStageGroupName(String stageId) {
    for (var entry in AppConstants.stageObject.entries) {
      final stages = entry.value['data'] as List;
      if (stages.any((stage) => stage['id'] == stageId)) {
        return entry.value['name'] as String;
      }
    }
    return null;
  }
}

class AvatarUtils {
  // Danh sách màu cho fallback avatar (tương tự react-avatar)
  static const List<Color> avatarColors = [
    Color(0xFFE53E3E), // red
    Color(0xFFD69E2E), // orange
    Color(0xFF38A169), // green
    Color(0xFF3182CE), // blue
    Color(0xFF805AD5), // purple
    Color(0xFFD53F8C), // pink
    Color(0xFF319795), // teal
    Color(0xFFE56B6F), // coral
  ];

  /// Tạo URL avatar từ string (tương tự getAvatarUrl trong utils.js)
  static String? getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;

    // Nếu đã là URL đầy đủ
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }

    // Nếu là đường dẫn tương đối, thêm base URL
    const String baseUrl = 'https://your-api-domain.com';
    return '$baseUrl/$avatarPath';
  }

  /// Lấy tên đầu và cuối từ họ tên (tương tự getFirstAndLastWord)
  static String getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return '?';
    }

    final words = fullName.trim().split(RegExp(r'\s+'));

    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// Tạo màu background cho avatar fallback
  static Color getAvatarColor(String text) {
    final bytes = utf8.encode(text);
    final hash = sha256.convert(bytes);
    final hashInt = hash.bytes.fold(0, (prev, byte) => prev + byte);
    return avatarColors[hashInt % avatarColors.length];
  }

  /// Kiểm tra xem URL có phải là ảnh không
  static bool isImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();

    return imageExtensions.any((ext) => lowerUrl.contains(ext));
  }
}

class AvatarMemoryManager {
  static final Map<String, Widget> _avatarCache = {};
  static const int maxCacheSize = 100;

  static Widget getOrCreateAvatar({
    required String cacheKey,
    required String displayName,
    String? imageUrl,
    double size = 44,
  }) {
    if (_avatarCache.containsKey(cacheKey)) {
      return _avatarCache[cacheKey]!;
    }

    final avatar = _createAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      size: size,
    );

    if (_avatarCache.length >= maxCacheSize) {
      _avatarCache.remove(_avatarCache.keys.first);
    }

    _avatarCache[cacheKey] = avatar;
    return avatar;
  }

  static Widget _createAvatar({
    String? imageUrl,
    required String displayName,
    double size = 44,
  }) {
    final initials = AvatarUtils.getInitials(displayName);
    final avatarColor = AvatarUtils.getAvatarColor(displayName);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: AvatarUtils.getAvatarUrl(imageUrl) ?? '',
        imageBuilder: (context, imageProvider) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) =>
            _buildTextAvatar(initials, avatarColor, size),
        errorWidget: (context, url, error) =>
            _buildTextAvatar(initials, avatarColor, size),
      );
    }

    return _buildTextAvatar(initials, avatarColor, size);
  }

  static Widget _buildTextAvatar(String initials, Color bgColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static void clearCache() {
    _avatarCache.clear();
  }
}
