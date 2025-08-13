import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:source_base/data/models/facebook_chat_response.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/chat_detail_page/model/message_model.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/widget/loading_indicator.dart';
import '../../blocs/chat/chat_aciton.dart';
import '../../blocs/customer_service/customer_service_action.dart';
import 'widget/assign_to_bottomsheet.dart';
import 'widget/download_file.dart';
import 'widget/full_image.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? organizationId;
  String? conversationId;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    organizationId = context.read<OrganizationBloc>().state.organizationId;
    conversationId = context.read<CustomerServiceBloc>().state.facebookChat?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInitialMessages();
    });

    _setupScrollListener();
  }

  void _loadInitialMessages() {
    context.read<ChatBloc>().add(LoadChat(
          organizationId: organizationId ?? '',
          conversationId: conversationId ?? '',
          limit: 20,
          offset: 0,
        ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    final chatState = context.read<ChatBloc>().state;
    if (chatState.chats.isEmpty) return;

    context.read<ChatBloc>().add(LoadChat(
          organizationId: organizationId ?? '',
          conversationId: conversationId ?? '',
          limit: 20,
          offset: chatState.chats.length,
        ));
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      context.read<ChatBloc>().add(SendMessage(
            user: context.read<OrganizationBloc>().state.user,
            organizationId: organizationId ?? '',
            conversationId: conversationId ?? '',
            message: message,
          ));
    } catch (e) {
      _showSnackBar('Không thể gửi tin nhắn: $e', isError: true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _handleFileSelected(image.path,
            isImage: true, fileName: image.name);
      }
    } catch (e) {
      _showSnackBar('Không thể chọn ảnh: $e', isError: true);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await _handleFileSelected(file.path!,
            isImage: false, fileName: file.name);
      }
    } catch (e) {
      _showSnackBar('Không thể chọn file: $e', isError: true);
    }
  }

  Future<void> _handleFileSelected(String filePath,
      {required bool isImage, required String fileName}) async {
    if (_isUploading) return;

    final currentMessage = _messageController.text.trim();
    _messageController.clear();
    FocusScope.of(context).unfocus();

    // Tạo local message ngay lập tức (optimistic UI)
    final localMessage = _createLocalMessage(
      content: currentMessage,
      filePath: filePath,
      fileName: fileName,
      isImage: isImage,
    );

    // Hiển thị tin nhắn local ngay lập tức
    context.read<ChatBloc>().add(AddMessage(message: localMessage));

    setState(() {
      _isUploading = true;
    });

    try {
      if (isImage) {
        context.read<ChatBloc>().add(SendImageMessage(
              organizationId: organizationId ?? '',
              conversationId: conversationId ?? '',
              textMessage: currentMessage,
              imageFile: XFile(filePath),
            ));
      } else {
        // TODO: Implement file sending
        _showSnackBar('Tính năng gửi file đang được phát triển');
      }
    } catch (e) {
      _showSnackBar('Không thể gửi file: $e', isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Tạo tin nhắn local theo format web
  Message _createLocalMessage({
    required String content,
    required String filePath,
    required String fileName,
    required bool isImage,
  }) {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';

    if (isImage) {
      // ẢNH: Lưu vào attachments
      return Message(
        id: '', // Không có id server
        localId: localId,
        conversationId: conversationId,
        messageId: localId,
        from: '124662217400086', // Page ID
        fromName: 'You',
        to: '',
        toName: '',
        message: content,
        isFromMe: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        isGpt: false,
        type: 'MESSAGE',
        fullName: 'You',
        status: 0,
        sending: true,
        attachments: [
          Attachment(
            type: 'image',
            url: 'file://$filePath', // Local file URL
            name: fileName,
            payload: {
              'url': 'file://$filePath',
              'name': fileName,
            },
          ),
        ],
      );
    } else {
      // FILE KHÁC: Lưu vào fileAttachment
      return Message(
        id: '', // Không có id server
        localId: localId,
        conversationId: conversationId,
        messageId: localId,
        from: '124662217400086', // Page ID
        fromName: 'You',
        to: '',
        isFromMe: true,
        toName: '',
        message: content,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        isGpt: false,
        type: 'MESSAGE',
        fullName: 'You',
        status: 0,
        sending: true,
        fileAttachment: FileAttachment(
          name: fileName,
          type: 'application/octet-stream',
          size: File(filePath).lengthSync(),
          url: 'file://$filePath', // Local file URL
        ),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  void _showAssignBottomSheet(FacebookChatModel conversation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => AssignToBottomSheet(
        organizationId: organizationId ?? '',
        workspaceId: 'temp_workspace_id',
        onSelected: (assignData) {
          // TODO: Implement assign logic
          _showSnackBar('Đã chuyển phụ trách thành công');
        },
        customerId: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      builder: (context, state) {
        final conversation =
            context.read<CustomerServiceBloc>().state.facebookChat;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                height: 0.5,
                color: Colors.grey,
              ),
            ),
            title: Row(
              children: [
                AppAvatar(
                  imageUrl: conversation?.personAvatar,
                  fallbackText: conversation?.personName,
                  size: 40,
                  shape: AvatarShape.circle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation?.personName ?? '',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        conversation?.pageName ?? '',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () => _showAssignBottomSheet(conversation!),
            //     icon: const Icon(Icons.swap_horiz),
            //   ),
            //   PopupMenuButton<String>(
            //     onSelected: (value) {
            //       // TODO: Handle menu actions
            //     },
            //     itemBuilder: (context) => [
            //       const PopupMenuItem(
            //         value: 'info',
            //         child: Row(
            //           children: [
            //             Icon(Icons.info),
            //             SizedBox(width: 8),
            //             Text('Thông tin khách hàng'),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ],
          ),
          body: Column(
            children: [
              // Upload indicator
              if (_isUploading)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[100],
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Đang tải lên...'),
                    ],
                  ),
                ),

              // Messages list
              Expanded(
                child: state.status == ChatStatus.loading && state.chats.isEmpty
                    ? const Center(child: LoadingIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: state.chats.length,
                        itemBuilder: (context, index) {
                          final message = state.chats[index];
                          final previousMessage = index < state.chats.length - 1
                              ? state.chats[index + 1]
                              : null;
                          final isFirstInTurn = previousMessage == null ||
                              previousMessage.from != message.from;

                          return _MessageBubble(
                            message: message,
                            showAvatar: isFirstInTurn,
                            isFirstInTurn: isFirstInTurn,
                          );
                        },
                      ),
              ),

              // Error display
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red[50],
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Input area
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _isUploading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                      ),
                      IconButton(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.attach_file),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          enabled: !_isUploading,
                        ),
                      ),
                      IconButton(
                        onPressed: _isUploading ? null : _sendMessage,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final bool isFirstInTurn;

  const _MessageBubble({
    required this.message,
    this.showAvatar = true,
    this.isFirstInTurn = true,
  });

  @override
  Widget build(BuildContext context) {
    final isFromMe = message.isFromMe;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisAlignment:
            isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromMe && showAvatar) ...[
            AppAvatar(
              imageUrl: message.senderAvatar,
              fallbackText: message.senderName,
              size: 32,
              shape: AvatarShape.circle,
            ),
            const SizedBox(width: 8),
          ] else ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isFromMe ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstInTurn && !isFromMe)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (message.content.isNotEmpty) ...[
                    if (isFirstInTurn && !isFromMe) const SizedBox(height: 4),
                    Text(
                      message.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  if (message.attachments?.isNotEmpty == true) ...[
                    if (message.content.isNotEmpty) const SizedBox(height: 8),
                    ...message.attachments!.map((attachment) {
                      if (attachment.type.toLowerCase().contains('image')) {
                        return _buildImageWidget(attachment.url);
                      }
                      return _buildFileWidget(
                          attachment.payload?["name"] ?? 'File');
                    }),
                  ],
                ],
              ),
            ),
          ),
          if (isFromMe && showAvatar) ...[
            const SizedBox(width: 8),
            AppAvatar(
              imageUrl: message.senderAvatar,
              fallbackText: message.senderName,
              size: 32,
              shape: AvatarShape.circle,
            ),
          ] else ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildImageWidget(String url) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.startsWith('file://')
          ? Image.file(File(url.replaceFirst('file://', '')), fit: BoxFit.cover)
          : Image.network(url, fit: BoxFit.cover),
    );
  }

  Widget _buildFileWidget(String fileName) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attachment, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
