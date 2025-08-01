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
  static const String getListMember =
      '$_prefix/organization/member/getlistpaging';
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
  static const String fbConnect = '$_prefix/auth/facebook/message';
  static const String conversationList =
      '$_prefix/omni/conversation/getlistpaging';
  static const String chatList = '$_prefix/social/message/getlistpaging';
  static const String sendMessage = '$_prefix/social/message/sendmessage';
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
  static const String getLeadPaging = '$_prefix2/lead/getlistpaging';
  static String postCustomerNote(String customerId) =>
      '$_prefix2/customer/$customerId/note';
  static String getJourneyPaging(String id) =>
      '$_prefix2/customer/$id/journey/getlistpaging';

  static String getListPage(
          String provider, String subscribed, String searchText) =>
      '$_prefix/integration/omnichannel/getlistpaging?Provider=$provider&Subscribed=$subscribed&searchText=$searchText&Fields=Name';
  static String updateStatusRead(String conversationId) =>
      '$_prefix/integration/omni/conversation/read/$conversationId';
  static String postArchiveCustomer(String id) =>
      '$_prefix2/customer/$id/archive';
  static String postUnArchiveCustomer(String id) =>
      '$_prefix2/customer/$id/archive/restore';
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
  static const String createReminder = '/Schedule';
}
