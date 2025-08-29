import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/app_constans.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/repositories/message_repository.dart';
import 'package:source_base/dio/service_locator.dart';
import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/auth/auth_event.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/shared/widgets/awesome_alert.dart';
import 'package:source_base/presentation/screens/shared/widgets/loading_dialog.dart';
import 'package:source_base/presentation/widget/dialog_member.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  /// Kiểm tra xem response có thành công hay không
  /// Hỗ trợ các mã: 0 (success), 200 (OK), 201 (Created)

  static Future<void> handleLogout(BuildContext context) async {
    showAwesomeAlert(
      context: context,
      title: 'Đăng xuất',
      description: 'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      icon: Icons.logout,
      isWarning: true,
      onConfirm: () async {
        try {
          // Thực hiện đăng xuất
          // await ApiClient.storage.deleteAll();
          if (context.mounted) {
            context.read<AuthBloc>().add(LogoutRequested());
            if (context.mounted) {
              context.replace('/');
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng xuất không thành công')),
            );
          }
        }
      },
    );
  }

  static String formatCurrency(num amount) {
    final format = NumberFormat.currency(
      locale: 'vi_VN', // Locale Việt Nam
      symbol: '₫', // Ký hiệu tiền
      decimalDigits: 0, // Không có phần thập phân
    );
    return format.format(amount);
  }

  static bool isResponseSuccess(Map<String, dynamic>? response) {
    if (response == null) return false;
    if (response['success'] == true) return true;
    if (response['StatusCode'] == 200) return true;
    final code = response['code'];
    return code == 0 || code == 200 || code == 201;
  }

  static void showSnackBar(BuildContext context, String message,
      {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor:
            backgroundColor ?? const Color.fromARGB(255, 236, 85, 75),
      ),
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

  void connectFacebookPage(BuildContext context) async {
    // TODO: Navigate to Facebook connection page

    LoginResult result;
    // if (Platform.isIOS) {
    //   // Bước 1: OIDC (Limited Login) – chỉ openid + profile cơ bản
    //   final r1 = await FacebookAuth.instance.login(
    //     permissions: const ['email', 'public_profile'],
    //     // iOS only: bật limited để nhận OIDC id_token
    //     loginTracking: LoginTracking.limited,
    //   );
    //   if (r1.status != LoginStatus.success) return;

    //   // TODO: lấy id_token nếu bạn cần (từ plugin theo hướng dẫn của bạn)

    //   // Bước 2: xin thêm quyền business/page/IG (KHÔNG có openid)
    // result = await FacebookAuth.instance.login(
    //   permissions: const [
    //     'pages_show_list',
    //     'pages_read_engagement',
    //     'pages_manage_metadata',
    //     'pages_manage_engagement',
    //     'pages_messaging',
    //     'instagram_basic',
    //     'instagram_manage_messages',
    //     'leads_retrieval',
    //   ],
    //   // classic login

    //   loginTracking: LoginTracking.limited,
    //   loginBehavior: LoginBehavior.webOnly,
    // );
    //   // r2.status == LoginStatus.success => đã có đủ quyền
    // } else {
    // Android: có thể xin 1 lần (không nên kèm openid để đồng bộ hành vi)
    result = await FacebookAuth.instance.login(
      permissions: const [
        'pages_show_list',
        'pages_read_engagement',
        'pages_manage_metadata',
        'pages_manage_engagement',
        'pages_messaging',
        'instagram_basic',
        'instagram_manage_messages',
        'leads_retrieval',
      ],
      // classic login

      loginTracking: LoginTracking.limited,
      loginBehavior: LoginBehavior.webOnly,
    );
    // }

    if (result.status == LoginStatus.success) {
      // Future.delayed(const Duration(milliseconds: 50), () => showLoadingDialog(context));

      final listPage = await DioClient().get(
        ApiEndpoints.getListPageFacebook(result.accessToken!.tokenString),
      );
      if (listPage.statusCode == 200) {
        final listPageData = jsonDecode(listPage.data)["data"];
        if (listPageData.isNotEmpty) {
          // Hiển thị dialog chọn trang
          final selected = await _showSelectFacebookPagesDialog(
            context,
            List<Map<String, dynamic>>.from(listPageData as List),
          );

          List<String> accessTokens = [];
          if (selected.isNotEmpty) {
            ShowdialogNouti(context,
                type: NotifyType.loading,
                title: "Đang kết nối với facebook",
                message: "Vui lòng chờ trong giây lát");
            for (var page in selected) {
              accessTokens.add(page['access_token']);
            }
            postToServer(context, accessTokens);
          }
          // TODO: dùng danh sách selected cho API liên kết theo nhu cầu backend
        }
      }
    } else {
      // errorAlert(title: "Thất bại", desc: "Đã có lỗi xảy ra, xin vui lòng thử lại");
    }
    print('Connect Facebook page');
  }

  Future<void> postToServer(
      BuildContext context, List<String> accessTokens) async {
    // TODO: Navigate to Facebook connection page

    MessageRepository(DioClient()).connectFacebook(
        context.read<OrganizationBloc>().state.organizationId ?? "",
        {"accessTokens": accessTokens}).then((res) {
      if (Helpers.isResponseSuccess(res)) {
        Navigator.of(context, rootNavigator: true).pop(); // Đóng dialog loading
        ShowdialogNouti(context,
            type: NotifyType.success,
            title: "Thành công",
            message: "Đã kết nối với facebook");
      } else {
        ShowdialogNouti(context,
            type: NotifyType.error, title: "Lỗi", message: res["message"]);
        // errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  Future<List<Map<String, dynamic>>> _showSelectFacebookPagesDialog(
    BuildContext context,
    List<Map<String, dynamic>> pages,
  ) async {
    final completer = Completer<List<Map<String, dynamic>>>();
    final Set<int> selected = {};
    bool selectAll = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            void toggleAll(bool value) {
              setState(() {
                selectAll = value;
                selected
                  ..clear()
                  ..addAll(
                      value ? List.generate(pages.length, (i) => i) : <int>{});
              });
            }

            void toggleOne(int index, bool value) {
              setState(() {
                if (value) {
                  selected.add(index);
                } else {
                  selected.remove(index);
                }
                selectAll = selected.length == pages.length;
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 560, maxHeight: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Chọn trang Facebook để kết nối',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectAll,
                            onChanged: (v) => toggleAll(v ?? false),
                          ),
                          Text('Chọn tất cả (${pages.length} trang)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: pages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final p = pages[i];
                          final String name = p['name'] ?? '';
                          final String id = p['id']?.toString() ?? '';
                          final String? avatar =
                              (p['picture']?['data']?['url']) as String?;
                          final bool isChecked = selected.contains(i);
                          return InkWell(
                            onTap: () => toggleOne(i, !isChecked),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (v) => toggleOne(i, v ?? false),
                                  ),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.1),
                                    backgroundImage:
                                        (avatar != null && avatar.isNotEmpty)
                                            ? NetworkImage(avatar)
                                            : null,
                                    child: (avatar == null || avatar.isEmpty)
                                        ? Text(
                                            (name.isNotEmpty ? name[0] : '?')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text('ID: $id',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(ctx).maybePop();
                                completer.complete(const []);
                              },
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selected.isEmpty
                                  ? null
                                  : () {
                                      final chosen = selected
                                          .map((i) => pages[i])
                                          .toList();
                                      Navigator.of(ctx).maybePop();
                                      completer.complete(chosen);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Kết nối ${selected.length} trang'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return completer.future;
  }

  void connectZaloPage(BuildContext context) async {
    // TODO: Navigate to Zalo connection page
    print('Connect Zalo page');
    String token = await getIt<SharedPreferencesService>()
            .getString(PrefKey.accessToken) ??
        '';

    String organizationId =
        context.read<OrganizationBloc>().state.organizationId ?? "";
    String url =
        '${DioClient.baseUrl}/api/v2/public/integration/auth/zalo/message?organizationId=$organizationId&accessToken=$token';

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  Future<void> connectTiktokPage(BuildContext context) async {
    // TODO: Navigate to Tiktok connection page
    print('Connect Tiktok page');
    String token = await getIt<SharedPreferencesService>()
            .getString(PrefKey.accessToken) ??
        '';

    String organizationId =
        context.read<OrganizationBloc>().state.organizationId ?? "";
    String url =
        '${DioClient.baseUrl}${ApiEndpoints.pushTiktokLeadLogin(organizationId, token)}';

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static void clearCache() {
    _avatarCache.clear();
  }
}

// Chat utility functions
// Chat utility functions
enum MessagePosition {
  single, // Tin nhắn đơn lẻ
  firstInReply, // Tin nhắn đầu trong chuỗi
  middleInReply, // Tin nhắn giữa chuỗi
  lastInReply, // Tin nhắn cuối chuỗi
}

class ChatHelpers {
  /// Xác định vị trí tin nhắn trong chuỗi
  static MessagePosition getMessagePosition(
      List messages, int index, String currentPersonId) {
    if (messages.isEmpty) return MessagePosition.single;

    final currentMessage = messages[index];
    final isFromCurrentPerson = currentMessage.from == currentPersonId;

    if (messages.length == 1) {
      return MessagePosition.single;
    } else if (index == 0) {
      final nextMessage = messages[index + 1];
      final nextIsFromCurrentPerson = nextMessage.from == currentPersonId;
      return isFromCurrentPerson == nextIsFromCurrentPerson
          ? MessagePosition.firstInReply
          : MessagePosition.single;
    } else if (index == messages.length - 1) {
      final prevMessage = messages[index - 1];
      final prevIsFromCurrentPerson = prevMessage.from == currentPersonId;
      return isFromCurrentPerson == prevIsFromCurrentPerson
          ? MessagePosition.lastInReply
          : MessagePosition.single;
    } else {
      final prevMessage = messages[index - 1];
      final nextMessage = messages[index + 1];
      final prevIsFromCurrentPerson = prevMessage.from == currentPersonId;
      final nextIsFromCurrentPerson = nextMessage.from == currentPersonId;

      if (isFromCurrentPerson != prevIsFromCurrentPerson &&
          isFromCurrentPerson == nextIsFromCurrentPerson) {
        return MessagePosition.firstInReply;
      } else if (isFromCurrentPerson == prevIsFromCurrentPerson &&
          isFromCurrentPerson != nextIsFromCurrentPerson) {
        return MessagePosition.lastInReply;
      } else if (isFromCurrentPerson == prevIsFromCurrentPerson &&
          isFromCurrentPerson == nextIsFromCurrentPerson) {
        return MessagePosition.middleInReply;
      } else {
        return MessagePosition.single;
      }
    }
  }

  /// Tạo border radius cho message bubble
  static BorderRadius getMessageBorderRadius(
      MessagePosition position, bool isFromUser) {
    if (isFromUser) {
      switch (position) {
        case MessagePosition.single:
          return BorderRadius.circular(14);
        case MessagePosition.lastInReply:
          return const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(3),
          );
        case MessagePosition.middleInReply:
          return const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(3),
          );
        case MessagePosition.firstInReply:
          return const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
          );
      }
    } else {
      switch (position) {
        case MessagePosition.single:
          return BorderRadius.circular(14);
        case MessagePosition.lastInReply:
          return const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(3),
            bottomLeft: Radius.circular(14),
          );
        case MessagePosition.middleInReply:
          return const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(3),
            bottomRight: Radius.circular(3),
            bottomLeft: Radius.circular(14),
          );
        case MessagePosition.firstInReply:
          return const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(3),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
          );
      }
    }
  }

  /// Format time difference
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Format time for message
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('dd/MM HH:mm').format(dateTime);
    }
  }

  /// Tạo avatar từ tên
  static Widget createCircleAvatar({
    required String name,
    double radius = 20,
    double? fontSize,
  }) {
    String initials = getInitials(name);
    Color avatarColor = getColorFromInitial(initials);

    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CircleAvatar(
        backgroundColor: avatarColor,
        radius: radius,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize ?? (radius * 0.6),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Lấy initials từ tên
  static String getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return (words.first[0] + words.last[0]).toUpperCase();
    }
  }

  /// Tạo màu từ initials
  static Color getColorFromInitial(String initials) {
    final colors = [
      const Color(0xFF5C33F0),
      const Color(0xFF0F5ABF),
      const Color(0xFF00A86B),
      const Color(0xFFFF6B35),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFFF39C12),
    ];

    int index = 0;
    for (int i = 0; i < initials.length; i++) {
      index += initials.codeUnitAt(i);
    }
    return colors[index % colors.length];
  }

  /// Get avatar provider từ URL/path
  static ImageProvider getAvatarProvider(String? imgData) {
    if (imgData == null || imgData.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }

    // Nếu là URL đầy đủ
    if (imgData.startsWith('https://') || imgData.startsWith('http://')) {
      return CachedNetworkImageProvider(
        imgData,
      );
    }

    // Nếu là base64
    if (imgData.startsWith('data:image')) {
      final base64String = imgData.split(',')[1];
      return MemoryImage(base64Decode(base64String));
    }

    // Nếu là relative path từ server - cần config API base URL
    try {
      return CachedNetworkImageProvider(imgData);
    } catch (e) {
      return const AssetImage('assets/images/default_avatar.png');
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Check if URL is image
  static bool isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext));
  }

  /// Check if URL is video
  static bool isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm'];
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.endsWith(ext));
  }
}

class OpenUrl {
  static void openUrl(String url) {
    if (url.startsWith('http')) {
      launchUrl(Uri.parse(url));
    } else {
      launchUrl(Uri.parse('https://$url'));
    }
  }
}
