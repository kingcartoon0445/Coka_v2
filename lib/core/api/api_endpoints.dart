// Tập hợp các endpoint API
class ApiEndpoints {
  // Base URL

  static const String login = '$_prefix/auth/login';
  static const String socialLogin = '$_prefix/auth/social/login';
  static const String verifyOtp = '$_prefix/otp/verify';
  static const String resendOtp = '$_prefix/otp/resend';
  static const String refreshToken = '$_prefix/account/refreshtoken';

  // User
  static const String profileDetail = '$_prefix/user/profile/getdetail';
  static const String profileUpdate = '$_prefix/user/profile/update';

  // Campaign
  static const String campaignBase = '$_prefix/campaigns';
  static const String campaignPaging = '$_prefix/campaign/getlistpaging';
  static const String organizationPaging =
      '$_prefix/organization/getlistpaging';
  static const String organizationDetail = '$_prefix/organization/detail';

  // Chatbot
  static const String chatbotPaging = '$_prefix/omni/chatbot/getlistpaging';
  static const String chatbotCreate = '$_prefix/omni/chatbot/create';

  static const String getUtmSource =
      '$_prefix2/category/utmsource/getlistpaging';
  static String chatbotDetail(String id) => '$_prefix/omni/chatbot/get/$id';
  static String chatbotUpdate(String id) => '$_prefix/omni/chatbot/update/$id';
  static String chatbotUpdateStatus(String id) =>
      '$_prefix/omni/chatbot/updatestatus/$id';

  static String chatbotConversationUpdateStatus(
          String conversationId, int status) =>
      '$_prefix/omni/conversation/updatechatbotstatus/$conversationId?Status=$status';
// Message & Conversation
  static const String fbConnect = '$_prefix2/integration/auth/facebook/lead';
  static String getListPageFacebook(String accessToken) =>
      'https://graph.facebook.com/v18.0/4096633283957751/accounts?fields=id,name,picture.type(normal),access_token&access_token=$accessToken';
  static const String conversationList =
      '$_prefix/omni/conversation/getlistpaging';

  static String sendMessage(String conversationId) =>
      '$_prefix2/chat/conversation/$conversationId/message/send';
  static const String assignConversation = '$_prefix/omni/conversation';
  static const String convertToLead = '$_prefix/omni/conversation';
  static const String subscriptionList =
      '$_prefix/integration/omnichannel/getlistpaging';
  static const String updateSubscription =
      '$_prefix/integration/omnichannel/updatestatus';
  static const String assignableUsers =
      '$_prefix/organization/workspace/user/getlistpaging';
  static const String teamList =
      '$_prefix/organization/workspace/team/getlistpaging';
  static const String getlistpaging = '$_prefix2/category/tags/getlistpaging';
  static String postCustomerNote(String customerId) =>
      '$_prefix2/lead/$customerId/journey/note';
  static String getJourneyPaging(String id) =>
      '$_prefix2/lead/$id/journey/getlistpaging';
  static String getListPage(
          String provider, String subscribed, String searchText) =>
      '$_prefix/integration/omnichannel/getlistpaging?Provider=$provider&Subscribed=$subscribed&searchText=$searchText&Fields=Name';
  static String updateStatusRead(String conversationId) =>
      '$_prefix/integration/omni/conversation/read/$conversationId';

// API Được sử dụng

  static String getListMember(String organizationId) =>
      '$_prefix/settings/permission/organization/getallmember?organizationId=$organizationId';
  static String createIntegration = '$_prefix2/lead/integration/webhook/create';
  static String getChannelList = '$_prefix2/lead/integration/connections';

  static String connectZaloOA(String organizationId, String accessToken) =>
      "$_prefix2/public/integration/auth/zalo/message?organizationId=$organizationId&accessToken=$accessToken";

  static String postArchiveCustomer(String id) => '$_prefix2/lead/$id/archive';
  static String getLeadDetail(String id) => '$_prefix2/lead/$id';
  static String searchOrganization(String searchText) =>
      '$_prefix2/organization/search?searchText=$searchText';
  static String createWebhook = '$_prefix2/lead/integration/webhook/create';
  static String getOrderDetailWithProduct(String id) =>
      '$_prefix/order/getOrderDetailWithProduct/$id';
  static String postUnArchiveCustomer(String id) =>
      '$_prefix2/lead/$id/archive/restore';
  static const String getLeadPaging = '$_prefix2/lead/getlistpagingv2';
  static String businessProcessTask = '$_prefix/businessprocesstask';
  static String linkOrder(String id) => '$businessProcessTask/$id/link-order';
  static String chatList(String conversationId) =>
      '$_prefix2/chat/conversation/$conversationId/message/getlistpaging';
  static String order = '$_prefix/order';
  static String duplicateOrder(String id) =>
      '$businessProcessTask/$id/duplicate';
  static String journeys(String id) => '$businessProcessTask/$id/journeys';

  static String archiveOrder(String conversationId) =>
      '$businessProcessTask/$conversationId/archive';
  static String getBusinessProcessTag = '$_prefix/BusinessProcessTag';
  static String getCustomerDetail(String id) => '$_prefix2/customer/$id';
  static String getCustomerPaging = '$_prefix2/customer/getlistpaging';

  static String getAllWorkspace =
      '$_prefix/settings/permission/organization/getallworkspace';
  static const String createWebForm =
      '$_prefix2/lead/integration/website/create';
  static String verifyWebForm(String id) =>
      '$_prefix2/lead/integration/website/$id/verify';
  static String connectChannel(String id) =>
      '$_prefix2/lead/integration/$id/status';

  static String getTiktokLeadConnections =
      '$_prefix2/auth/tiktok/lead/connections';

  static String getTiktokItemList(
          String organizationId, String subscribedId, String isConnect) =>
      '$_prefix2/lead/integration/tiktok/getlist?organizationId=$organizationId&SubscribedId=$subscribedId&IsConnect=$isConnect';

  static String getTiktokConfiguration(String connectionId, String pageId) =>
      '$_prefix2/lead/integration/tiktok/undefined?connectionId=$connectionId&pageId=$pageId';

  static String disconnectChannel(String id, String provider) =>
      '$_prefix2/lead/integration/$id?provider=$provider';
  static String pushTiktokLeadLogin(
          String organizationId, String accessToken) =>
      '$_prefix2/public/integration/auth/tiktok/lead?organizationId=$organizationId&accessToken=$accessToken';
  static String getProduct = '$_prefix/Product';
  static String businessProcessTemplate = "$_prefix/businessprocesstemplate";
  static String createLead = '$_prefix2/lead/create';
  static String acceptInvitation(String id) =>
      '$_prefix2/organization/members/requests/$id/accept';
  static String rejectInvitation(String id) =>
      '$_prefix2/organization/members/requests/$id/reject';
  static String getBusinessProcess(
    String workspaceId,
  ) =>
      '$_prefix/BusinessProcessStage/workspace/$workspaceId';
  static String joinOrganization =
      '$_prefix2/organization/members/join-requests';
  static String getInvitationList(String type) =>
      '$_prefix2/organization/members/join-requests?type=$type';
  // /api/v1/integration/omni/conversation/read/{conversationId}
  // Prefix
  static const String _prefix = '/api/v1';
  static const String _prefix2 = '/api/v2';

  // Các endpoint khác
  // ...
// API Caculator
  static String getCalculator(String organizationId, String contactId) =>
      '/Schedule?organizationId=$organizationId&workspaceId=&contactId=$contactId';
  static const String updateNoteMark = '/Schedule/mark-as-done';
  static const String schedule = '/Schedule';
  static const String webForm = '/webform';
}
