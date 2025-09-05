/// Tập hợp các endpoint API (refactor)
/// - Sử dụng Uri builder để an toàn & dễ bảo trì
/// - _v1 / _v2 tạo path tương đối '/api/v1' & '/api/v2'
/// - _abs dành cho các absolute URL (Facebook Graph, v.v.)
final class ApiEndpoints {
  ApiEndpoints._();

  // Prefix
  static const String _v1Prefix = '/api/v1';
  static const String _v2Prefix = '/api/v2';

  // ===== Helpers ============================================================

  /// Build URL tương đối dưới /api/v1
  static String _v1(String path, [Map<String, Object?>? qp]) =>
      Uri(path: '$_v1Prefix/$path', queryParameters: _qp(qp)).toString();

  /// Build URL tương đối dưới /api/v2
  static String _v2(String path, [Map<String, Object?>? qp]) =>
      Uri(path: '$_v2Prefix/$path', queryParameters: _qp(qp)).toString();

  /// Build absolute URL (ví dụ Facebook Graph)
  static String _abs(String base, [Map<String, Object?>? qp]) =>
      Uri.parse(base).replace(queryParameters: _qp(qp)).toString();

  /// Chuẩn hoá query parameters:
  /// - Bỏ key có value null
  /// - bool -> 'true'/'false'
  /// - int/num -> toString()
  static Map<String, String>? _qp(Map<String, Object?>? qp) {
    if (qp == null || qp.isEmpty) return null;
    final out = <String, String>{};
    qp.forEach((k, v) {
      if (v == null) return;
      switch (v) {
        case bool b:
          out[k] = b.toString();
        case num n:
          out[k] = n.toString();
        default:
          out[k] = v.toString();
      }
    });
    return out.isEmpty ? null : out;
  }

  // ===== Auth ===============================================================

  static String login() => _v1('auth/login');
  static String socialLogin() => _v1('auth/social/login');
  static String verifyOtp() => _v1('otp/verify');
  static String resendOtp() => _v1('otp/resend');
  static String refreshToken() => _v1('account/refreshtoken');

  // ===== User ===============================================================

  static String profileDetail() => _v1('user/profile/getdetail');
  static String profileUpdate() => _v1('user/profile/update');

  // ===== Campaign / Organization ===========================================

  static String campaignBase() => _v1('campaigns');
  static String campaignPaging() => _v1('campaign/getlistpaging');

  static String organizationPaging() => _v1('organization/getlistpaging');
  static String organizationDetail() => _v1('organization/detail');

  // ===== Chatbot / Omni =====================================================

  static String chatbotPaging() => _v1('omni/chatbot/getlistpaging');
  static String chatbotCreate() => _v1('omni/chatbot/create');
  static String chatbotDetail(String id) => _v1('omni/chatbot/get/$id');
  static String chatbotUpdate(String id) => _v1('omni/chatbot/update/$id');
  static String chatbotUpdateStatus(String id) =>
      _v1('omni/chatbot/updatestatus/$id');

  static String chatbotConversationUpdateStatus(
    String conversationId, {
    required int status,
  }) =>
      _v1('omni/conversation/updatechatbotstatus/$conversationId', {
        'Status': status,
      });

  // ===== Message & Conversation ============================================

  static String conversationList() => _v1('omni/conversation/getlistpaging');

  static String assignConversation() => _v1('omni/conversation');
  static String convertToLead() => _v1('omni/conversation');

  static String updateStatusRead(String conversationId) =>
      _v1('integration/omni/conversation/read/$conversationId');

  static String getDetailConversation(String conversationId) =>
      _v2('chat/conversation/$conversationId');

  static String chatList(String conversationId) =>
      _v2('chat/conversation/$conversationId/message/getlistpaging');

  static String sendMessage(String conversationId) =>
      _v2('chat/conversation/$conversationId/message/send');

  static String linkToLead(String conversationId) =>
      _v2('chat/conversation/$conversationId/link-to-lead');

  // ===== Integration / Subscription ========================================

  static String subscriptionList() =>
      _v1('integration/omnichannel/getlistpaging');

  static String updateSubscription() =>
      _v1('integration/omnichannel/updatestatus');

  static String assignableUsers() =>
      _v1('organization/workspace/user/getlistpaging');

  static String teamList() => _v1('organization/workspace/team/getlistpaging');

  static String getListPage({
    required String provider,
    required bool subscribed,
    String searchText = '',
  }) =>
      _v1('integration/omnichannel/getlistpaging', {
        'Provider': provider,
        'Subscribed': subscribed,
        'searchText': searchText,
        'Fields': 'Name',
      });

  static String getlistpagingTags() => _v2('category/tags/getlistpaging');
  static String getUtmSource() => _v2('category/utmsource/getlistpaging');

  // ===== Facebook Graph (absolute) =========================================

  static const _fbGraphVersion = 'v18.0';
  static const _fbPageId = '4096633283957751';

  static String fbConnectLead() => _v2('integration/auth/facebook/lead');

  static String getListPageFacebook(String accessToken) => _abs(
        'https://graph.facebook.com/$_fbGraphVersion/$_fbPageId/accounts',
        {
          'fields': 'id,name,picture.type(normal),access_token',
          'access_token': accessToken,
        },
      );

  // ===== Customer / Lead / Journey =========================================

  static String postCustomerNote(String customerId) =>
      _v2('lead/$customerId/journey/note');

  static String getJourneyPaging(String leadId) =>
      _v2('lead/$leadId/journey/getlistpaging');

  static String getLeadDetail(String id) => _v2('lead/$id');
  static String getLeadPaging() => _v2('lead/getlistpagingv2');
  static String createLead() => _v2('lead/create');

  static String postArchiveCustomer(String id) => _v2('lead/$id/archive');
  static String postUnArchiveCustomer(String id) =>
      _v2('lead/$id/archive/restore');

  static String getCustomerDetail(String id) => _v2('customer/$id');
  static String getCustomerPaging() => _v2('customer/getlistpaging');

  // ===== Product / Order / Business Process =================================

  static String product() => _v1('Product');
  static String order() => _v1('order');

  static String getOrderDetailWithProduct(String id) =>
      _v1('order/getOrderDetailWithProduct/$id');

  static String businessProcessTask() => _v1('businessprocesstask');
  static String businessProcessTemplate() => _v1('businessprocesstemplate');

  static String linkOrder(String taskId) =>
      _v1('businessprocesstask/$taskId/link-order');

  static String duplicateOrder(String taskId) =>
      _v1('businessprocesstask/$taskId/duplicate');

  static String journeys(String taskId) =>
      _v1('businessprocesstask/$taskId/journeys');

  static String archiveOrder(String taskId) =>
      _v1('businessprocesstask/$taskId/archive');

  static String getBusinessProcessTag() => _v1('BusinessProcessTag');

  static String getBusinessProcessByWorkspace(String workspaceId) =>
      _v1('BusinessProcessStage/workspace/$workspaceId');

  // ===== Organization / Workspace ===========================================

  static String getListMember(String organizationId) => _v1(
        'settings/permission/organization/getallmember',
        {'organizationId': organizationId},
      );

  static String getAllWorkspace() =>
      _v1('settings/permission/organization/getallworkspace');

  static String searchOrganization(String searchText) =>
      _v2('organization/search', {'searchText': searchText});

  static String joinOrganization() => _v2('organization/members/join-requests');

  static String getInvitationList(String type) =>
      _v2('organization/members/join-requests', {'type': type});

  static String acceptInvitation(String id) =>
      _v2('organization/members/requests/$id/accept');

  static String rejectInvitation(String id) =>
      _v2('organization/members/requests/$id/reject');

  // ===== Integration: Webhook / Website / Channels ==========================

  // (Gộp trùng: createIntegration == createWebhook)
  static String createWebhook() => _v2('lead/integration/webhook/create');

  static String getChannelList() => _v2('lead/integration/connections');

  static String createWebForm() => _v2('lead/integration/website/create');

  static String verifyWebForm(String id) =>
      _v2('lead/integration/website/$id/verify');

  static String connectChannel(String id) => _v2('lead/integration/$id/status');

  static String disconnectChannel(String id, String provider) =>
      _v2('lead/integration/$id', {'provider': provider});

  // ===== Integration: Zalo / TikTok =========================================

  static String connectZaloOA(String organizationId, String accessToken) =>
      _v2('public/integration/auth/zalo/message', {
        'organizationId': organizationId,
        'accessToken': accessToken,
      });

  static String pushTiktokLeadLogin(
    String organizationId,
    String accessToken,
  ) =>
      _v2('public/integration/auth/tiktok/lead', {
        'organizationId': organizationId,
        'accessToken': accessToken,
      });

  static String getTiktokLeadConnections() =>
      _v2('auth/tiktok/lead/connections');

  static String getTiktokItemList({
    required String organizationId,
    required String subscribedId,
    required bool isConnect,
  }) =>
      _v2('lead/integration/tiktok/getlist', {
        'organizationId': organizationId,
        'SubscribedId': subscribedId,
        'IsConnect': isConnect,
      });

  /// TODO: API spec ghi 'undefined' – giữ nguyên cho tới khi BE cập nhật.
  static String getTiktokConfiguration({
    required String connectionId,
    required String pageId,
  }) =>
      _v2('lead/integration/tiktok/undefined', {
        'connectionId': connectionId,
        'pageId': pageId,
      });

  // ===== Schedule / Calculator / WebForm (public) ===========================

  static String getCalculator({
    required String organizationId,
    required String contactId,
    String workspaceId = '',
  }) =>
      Uri(
        path: '/Schedule',
        queryParameters: _qp({
          'organizationId': organizationId,
          'workspaceId': workspaceId,
          'contactId': contactId,
        }),
      ).toString();

  static String updateNoteMark() => '/Schedule/mark-as-done';
  static String schedule() => '/Schedule';
  static String webForm() => '/webform';
}
