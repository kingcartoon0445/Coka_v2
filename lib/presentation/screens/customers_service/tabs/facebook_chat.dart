import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/repositories/message_repository.dart';
import 'package:source_base/dio/service_locator.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/widgets/message_item.dart';
import 'package:source_base/presentation/screens/customers_service/widgets/web_view.dart';
import 'package:source_base/presentation/screens/shared/widgets/awesome_alert.dart';
import 'package:source_base/presentation/screens/shared/widgets/enhanced_avatar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../blocs/customer_service/customer_service_action.dart';

class FacebookMessagesTab extends StatefulWidget {
  final String provider;
  const FacebookMessagesTab({
    super.key,
    required this.provider,
  });

  @override
  State<FacebookMessagesTab> createState() => _FacebookMessagesTabState();
}

class _FacebookMessagesTabState extends State<FacebookMessagesTab> {
  final _scrollController = ScrollController();
  bool _isFirstBuild = true;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load Facebook chats when widget initializes
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<CustomerServiceBloc>().add(LoadFacebookChat(
    //         organizationId: widget.organizationId,
    //       ));
    // });

    // ref
    //     .read(facebookMessageProvider.notifier)
    //     .setupFirebaseListener(widget.organizationId, context);
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<CustomerServiceBloc>().add(LoadFirstProviderChat(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? "",
          provider: widget.provider,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<CustomerServiceBloc>().state;
      if (state.status != CustomerServiceStatus.loadingMore &&
          state.hasMoreFacebookChats) {
        final currentOffset = state.facebookChatsMetadata?.offset ?? 0;
        final currentCount = state.facebookChatsMetadata?.count ?? 0;
        final nextOffset = currentOffset + currentCount;

        print('🔍 Triggering load more - offset: $nextOffset, limit: 20');
        context.read<CustomerServiceBloc>().add(LoadMoreProviderChats(
              organizationId:
                  context.read<OrganizationBloc>().state.organizationId ?? "",
              limit: 20,
              offset: nextOffset,
              provider: widget.provider,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
        builder: (context, state) {
      print('🔍 UI State - Status: ${state.status}');
      print(
          '🔍 UI State - Facebook chats count: ${state.customerServices.length}');
      print(
          '🔍 UI State - Has more Facebook chats: ${state.hasMoreFacebookChats}');
      print(
          '🔍 UI State - Facebook chats metadata: ${state.facebookChatsMetadata}');

      // final state = ref.watch(customerServiceProvider);
      if (state.status == CustomerServiceStatus.loading) {
        return _buildShimmerItem();
      }

      if (state.status != CustomerServiceStatus.loading &&
          state.customerServices.isEmpty) {
        return _buildEmptyState(widget.provider);
      }
      // Khi gọi ChangeStatusRead, conversationes (state.facebookChats) sẽ chỉ thay đổi nếu bloc emit một state mới với facebookChats đã được cập nhật.
      // Nếu conversationes không thay đổi sau khi gọi ChangeStatusRead, có thể là do:
      // 1. Bloc không emit state mới (ví dụ: nếu conversationId không khớp, hoặc emit với cùng instance list).
      // 2. UI không rebuild vì state.facebookChats không phải là một list mới (cùng instance).
      // Để đảm bảo UI cập nhật, trong bloc cần emit một list mới (copy) khi cập nhật isRead, ví dụ:
      // emit(state.copyWith(facebookChats: List.from(state.facebookChats)));

      final conversationes = state.customerServices;
      return Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            itemCount: state.customerServices.length +
                (state.hasMoreFacebookChats ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end if there are more items to load
              if (index == state.customerServices.length) {
                return state.hasMoreFacebookChats
                    ? _buildLoadingMoreIndicator()
                    : const SizedBox();
              }

              final conversation = conversationes[index];
              return MessageItem(
                isRead: true, //conversation.isRead ?? false,
                id: conversation.id ?? '',
                organizationId:
                    context.read<OrganizationBloc>().state.organizationId ?? "",
                sender: conversation.fullName ?? '',
                content: conversation.snippet ?? '',
                time: conversation.createdDate != null
                    ? conversation.createdDate!
                    : DateTime.now(),
                isFileMessage:
                    conversation.snippet == null || conversation.snippet == '',
                platform: conversation.channel ?? '',
                avatar: conversation.avatar,
                pageAvatar: conversation.pageAvatar,
                facebookChat: conversation,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(String provider) {
    return Container(
      color: const Color(0xFFF8F8F8),
      child: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (provider == 'FACEBOOK') ...[
              SizedBox(
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.facebook,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có tin nhắn Facebook nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kết nối trang Facebook để nhận tin nhắn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _connectFacebookPage(),
                      icon: const Icon(Icons.add_link),
                      label: const Text('Kết nối trang Facebook'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF554FE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(
                    //   Icons.facebook,
                    //   size: 64,
                    //   color: Colors.grey[400],
                    // ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có tin nhắn Zalo nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kết nối trang Zalo để nhận tin nhắn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _connectZaloPage(),
                      icon: const Icon(Icons.add_link),
                      label: const Text('Kết nối trang Zalo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 79, 148, 232),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Widget _buildConversationList() {
  //   return Container(
  //     color: const Color(0xFFF8F8F8),
  //     child: RefreshIndicator(
  //       onRefresh: () async {
  //         context.read<CustomerServiceBloc>().add(LoadFacebookChat(
  //               organizationId: widget.organizationId,
  //             ));
  //         // ref.read(facebookMessageProvider.notifier).reset();
  //         // await ref.read(facebookMessageProvider.notifier).fetchConversations(
  //         //       widget.organizationId,
  //         //       forceRefresh: true,
  //         //     );
  //       },
  //       child: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
  //           bloc: context.read<CustomerServiceBloc>(),
  //           builder: (context, state) {
  //             if (state.status == CustomerServiceStatus.loadingFacebookChat) {
  //               List<CustomerServiceModel> facebookChats = state.facebookChats;
  //               if (facebookChats.isEmpty) {}
  //             }

  //             return ListView.separated(
  //               physics: const AlwaysScrollableScrollPhysics(),
  //               controller: _scrollController,
  //               itemCount: state.facebookChats.length,
  //               separatorBuilder: (context, index) => const Divider(
  //                 height: 1,
  //                 thickness: 0.5,
  //                 color: Color(0xFFE5E5E5),
  //               ),
  //               itemBuilder: (context, index) {
  //                 if (index == state.facebookChats.length) {
  //                   return state.facebookChats.isNotEmpty
  //                       ? _buildLoadingMoreIndicator()
  //                       : const SizedBox();
  //                 }

  //                 final conversation = state.facebookChats[index];
  //                 return MessageItem(
  //                   isRead: conversation.isRead ?? false,
  //                   id: conversation.id ?? '',
  //                   organizationId: widget.organizationId,
  //                   sender: conversation.personName ?? '',
  //                   isFileMessage: false,
  //                   content: conversation.snippet ?? '',
  //                   time: conversation.updatedTime?.toString() ?? '',
  //                   platform: conversation.provider ?? '',
  //                   avatar: conversation.personAvatar,
  //                   pageAvatar: conversation.pageAvatar,
  //                 );
  //               },
  //             );
  //           }),
  //     ),
  //   );
  // }

  Widget _buildLoadingMoreIndicator() {
    return BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
      builder: (context, state) {
        if (state.status == CustomerServiceStatus.loadingMore) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF554FE8),
              ),
            ),
          );
        } else if (state.hasMoreFacebookChats) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'Kéo xuống để tải thêm',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildEnhancedMessageItem(
      CustomerServiceModel conversation, int index) {
    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: () => _navigateToChat(conversation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar with online indicator
              _buildConversationAvatar(conversation),

              const SizedBox(width: 12),

              // CustomerServiceModel info
              Expanded(
                child: _buildConversationInfo(conversation),
              ),

              const SizedBox(width: 8),

              // Time and badges
              _buildConversationMeta(conversation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationAvatar(CustomerServiceModel conversation) {
    return Stack(
      children: [
        // Main avatar
        CustomAvatar(
          imageUrl: conversation.avatar,
          displayName: conversation.fullName ?? '',
          size: 48,
          showBorder: true,
          borderColor: Colors.white,
          borderWidth: 2,
        ),

        // Page avatar overlay (Facebook logo)
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2), // Facebook blue
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.facebook,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),

        // Online status (based on recent activity)
        if (true)
          Positioned(
            top: 0,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConversationInfo(CustomerServiceModel conversation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer name
        Text(
          conversation.fullName ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2),

        // Last message preview
        Text(
          conversation.snippet ?? '',
          style: TextStyle(
            fontSize: 14,
            color: true ? Colors.black87 : Colors.grey[600],
            fontWeight: true ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildConversationMeta(CustomerServiceModel conversation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Time
        Text(
          ChatHelpers.getTimeAgo(DateTime.fromMillisecondsSinceEpoch(
              conversation.createdDate!.millisecondsSinceEpoch)),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 4),

        // Badges
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Unread indicator (if not read)
            if (true)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF554FE8),
                  shape: BoxShape.circle,
                ),
              ),

            // Assigned indicator
            if (conversation.fullName != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.person,
                color: Colors.green[600],
                size: 16,
              ),
            ],

            // GPT status indicator
            if (false) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.smart_toy,
                color: Colors.blue[600],
                size: 16,
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _navigateToChat(CustomerServiceModel conversation) {
    // TODO: Navigate to chat detail page
    print('Navigate to chat: ${conversation.id}');
  }

  void _connectZaloPage() async {
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

  void _connectFacebookPage() async {
    // TODO: Navigate to Facebook connection page

    final result = await FacebookAuth.i.login(
      permissions: [
        "email",
        "openid",
        "pages_show_list",
        "pages_messaging",
        "instagram_basic",
        "leads_retrieval",
        "instagram_manage_messages",
        "pages_read_engagement",
        "pages_manage_metadata",
        "pages_read_user_content",
        "pages_manage_engagement",
        "public_profile"
      ],
    );

    if (result.status == LoginStatus.success) {
      // Future.delayed(const Duration(milliseconds: 50), () => showLoadingDialog(context));

      MessageRepository(DioClient()).connectFacebook(
          context.read<OrganizationBloc>().state.organizationId ?? "",
          {"socialAccessToken": result.accessToken!.tokenString}).then((res) {
        if (Helpers.isResponseSuccess(res)) {
          // final chatChannelController = Get.put(ChatChannelController());
          // chatChannelController.onRefresh();
          // Get.back();
          // Navigator.of(context).pop(); // Đóng dialog loading
          // Đóng dialog loading
          successAlert(title: "Thành công", desc: "Đã kết nối với facebook");
        } else {
          // errorAlert(title: "Lỗi", desc: res["message"]);
        }
      });
    } else {
      // errorAlert(title: "Thất bại", desc: "Đã có lỗi xảy ra, xin vui lòng thử lại");
    }
    print('Connect Facebook page');
  }
}
