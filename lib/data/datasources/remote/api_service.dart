// ignore_for_file: unnecessary_lambdas
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart'
    show LeadPagingRequest;
import 'package:source_base/dio/service_locator.dart';

typedef Json = Map<String, dynamic>;

class ApiService {
  final DioClient _dioClient;
  final SharedPreferencesService _prefsService =
      getIt<SharedPreferencesService>();
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  ApiService(
    this._dioClient, {
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              forceCodeForRefreshToken: true,
            ),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  // ------------------------------
  // Helpers
  // ------------------------------

  Options _org(String organizationId) =>
      Options(headers: {'organizationId': organizationId});

  Map<String, dynamic> _compact(Map<String, dynamic?> source) {
    final m = <String, dynamic>{};
    source.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.isEmpty) return;
      m[k] = v;
    });
    return m;
  }

  Response<Map<String, dynamic>> _error(String path, Object e,
      {int status = 500, String code = 'unknown_error'}) {
    return Response<Map<String, dynamic>>(
      data: {
        'success': false,
        'error': code,
        'message': e.toString(),
      },
      statusCode: status,
      statusMessage: code,
      requestOptions: RequestOptions(path: path),
    );
  }

  Future<Response> _safe(String path, Future<Response> Function() call) async {
    try {
      return await call();
    } catch (e) {
      return _error(path, e);
    }
  }

  MediaType _mediaTypeFromPath(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return MediaType.parse('image/png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType.parse('image/jpeg');
    }
    if (lower.endsWith('.gif')) return MediaType.parse('image/gif');
    return MediaType.parse('application/octet-stream');
  }

  Future<FormData> _formDataFromMap(Json data,
      {File? file, String fileField = 'avatar'}) async {
    final fd = FormData();
    data.forEach((k, v) {
      if (v != null) fd.fields.add(MapEntry(k, v.toString()));
    });
    if (file != null) {
      final fileName = file.path.split('/').last;
      fd.files.add(MapEntry(
        fileField,
        await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: _mediaTypeFromPath(fileName),
        ),
      ));
    }
    return fd;
  }

  String? _fieldOf(FormData fd, String key) {
    for (final f in fd.fields) {
      if (f.key == key) return f.value;
    }
    return null;
  }

  // ------------------------------
  // Auth
  // ------------------------------

  Future<Response> loginService(String email) => _safe(
        ApiEndpoints.login(),
        () => _dioClient.post(ApiEndpoints.login(), data: {'userName': email}),
      );

  Future<Response> verifyOTPService({
    required String otpId,
    required String otpCode,
  }) =>
      _safe(
        ApiEndpoints.verifyOtp(),
        () => _dioClient.post(
          ApiEndpoints.verifyOtp(),
          data: {'otpId': otpId, 'code': otpCode},
        ),
      );

  Future<Response> reSendOtpService(String otpID) => _safe(
        ApiEndpoints.resendOtp(),
        () => _dioClient.post(ApiEndpoints.resendOtp(), data: {'otpId': otpID}),
      );

  Future<Response> getUserInfoService() => _safe(
        ApiEndpoints.profileDetail(),
        () => _dioClient.get(ApiEndpoints.profileDetail()),
      );

  Future<Response> updateProfileService(Json data, {File? avatar}) => _safe(
        ApiEndpoints.profileUpdate(),
        () async => _dioClient.patch(
          ApiEndpoints.profileUpdate(),
          data: await _formDataFromMap(data, file: avatar, fileField: 'avatar'),
        ),
      );

  Future<Response> loginWithGoogle({bool forceNewAccount = false}) async {
    if (forceNewAccount) {
      await _googleSignIn.signOut();
    }
    return _safe('/login/google', () async {
      final user = await _googleSignIn.signIn();
      if (user == null) throw Exception('Đăng nhập Google bị hủy');
      final auth = await user.authentication;
      final token = auth.accessToken;
      if (token == null) throw Exception('Không thể lấy token Google');
      return socialLogin(token, 'google');
    });
  }

  Future<Response> loginWithFacebook({bool forceNewAccount = false}) async {
    if (forceNewAccount) await _facebookAuth.logOut();
    return _safe('/login/facebook', () async {
      final result = await _facebookAuth
          .login(permissions: const ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final token = result.accessToken?.tokenString;
        if (token == null) throw Exception('Không thể lấy token Facebook');
        return socialLogin(token, 'facebook');
      }
      if (result.status == LoginStatus.cancelled) {
        throw Exception('Đăng nhập Facebook bị hủy');
      }
      throw Exception('Đăng nhập Facebook thất bại');
    });
  }

  Future<Response> socialLogin(String accessToken, String provider) => _safe(
        ApiEndpoints.socialLogin(),
        () => _dioClient.post(
          ApiEndpoints.socialLogin(),
          data: {'accessToken': accessToken, 'provider': provider},
        ),
      );

  // ------------------------------
  // Organizations / Leads / Customers
  // ------------------------------

  Future<Response> getOrganizationsService({
    required String limit,
    required String offset,
    required String searchText,
  }) =>
      _safe(ApiEndpoints.organizationPaging(), () {
        final qp = _compact(
            {'limit': limit, 'offset': offset, 'searchText': searchText});
        return _dioClient.get(ApiEndpoints.organizationPaging(),
            queryParameters: qp);
      });

  Future<Response> getCustomerService(
    String organizationId, {
    required LeadPagingRequest pagingRequest,
  }) =>
      _safe(ApiEndpoints.getLeadPaging(), () {
        return _dioClient.post(
          ApiEndpoints.getLeadPaging(),
          data: pagingRequest.toJson(),
          options: _org(organizationId),
        );
      });

  Future<Response> getJourneyPagingService(
    String id,
    String organizationId, {
    int? limit,
    int? offset,
    String? type,
  }) =>
      _safe(ApiEndpoints.getJourneyPaging(id), () {
        final qp = _compact({'limit': limit, 'offset': offset, 'type': type});
        return _dioClient.get(
          ApiEndpoints.getJourneyPaging(id),
          queryParameters: qp.isEmpty ? null : qp,
          options: _org(organizationId),
        );
      });

  Future<Response> getUtmSource(String organizationId) => _safe(
        ApiEndpoints.getUtmSource(),
        () => _dioClient.get(ApiEndpoints.getUtmSource(),
            options: _org(organizationId)),
      );

  /// Tags paging (đổi từ getlistpaging -> getlistpagingTags)
  Future<Response> getListPaging(String organizationId) => _safe(
        ApiEndpoints.getlistpagingTags(),
        () => _dioClient.get(ApiEndpoints.getlistpagingTags(),
            options: _org(organizationId)),
      );

  Future<Response> getListMember(String organizationId) => _safe(
        ApiEndpoints.getListMember(organizationId),
        () => _dioClient.get(ApiEndpoints.getListMember(organizationId),
            options: _org(organizationId)),
      );

  Future<Response> getOrganizationDetailService(String organizationId) => _safe(
        '${ApiEndpoints.organizationDetail()}/$organizationId',
        () => _dioClient
            .get('${ApiEndpoints.organizationDetail()}/$organizationId'),
      );

  Future<Response> refreshTokenService(String refreshToken) => _safe(
        ApiEndpoints.refreshToken(),
        () => _dioClient.post(ApiEndpoints.refreshToken(),
            data: {'refreshToken': refreshToken}),
      );

  Future<Response> postCustomerNoteService(
          String customerId, String note, String organizationId) =>
      _safe(
        ApiEndpoints.postCustomerNote(customerId),
        () => _dioClient.post(
          ApiEndpoints.postCustomerNote(customerId),
          options: _org(organizationId),
          data: {'note': note},
        ),
      );

  Future<Response> postArchiveCustomerService(
          String id, String organizationId) =>
      _safe(
        ApiEndpoints.postArchiveCustomer(id),
        () => _dioClient.post(ApiEndpoints.postArchiveCustomer(id),
            options: _org(organizationId)),
      );

  Future<Response> postUnArchiveCustomerService(
          String id, String organizationId) =>
      _safe(
        ApiEndpoints.postUnArchiveCustomer(id),
        () => _dioClient.post(ApiEndpoints.postUnArchiveCustomer(id),
            options: _org(organizationId)),
      );

  Future<Response> getChatListService(String organizationId,
          String conversationId, int limit, int offset) =>
      _safe(
        ApiEndpoints.chatList(conversationId),
        () => _dioClient.get(
          ApiEndpoints.chatList(conversationId),
          options: _org(organizationId),
          queryParameters: {'limit': limit, 'offset': offset},
        ),
      );

  Future<Response> updateStatusReadService(
          String conversationId, String organizationId) =>
      _safe(
        ApiEndpoints.updateStatusRead(conversationId),
        () => _dioClient.patch(
          ApiEndpoints.updateStatusRead(conversationId),
          options: _org(organizationId),
        ),
      );

  Future<Response> sendMessageService(
          String organizationId, String conversationId, FormData formData) =>
      _safe(
        ApiEndpoints.sendMessage(conversationId),
        () => _dioClient.post(
          ApiEndpoints.sendMessage(
              _fieldOf(formData, 'conversationId') ?? conversationId),
          options: _org(organizationId),
          data: formData,
        ),
      );

  Future<Response> sendImageMessageService(
          String organizationId, FormData formData) =>
      _safe(
        ApiEndpoints.sendMessage(_fieldOf(formData, 'conversationId') ?? ''),
        () => _dioClient.post(
          ApiEndpoints.sendMessage(_fieldOf(formData, 'conversationId') ?? ''),
          options: _org(organizationId),
          data: formData,
        ),
      );

  Future<Response> deleteCustomerService(String id, String organizationId) =>
      _safe(
        ApiEndpoints.getLeadDetail(id),
        () => _dioClient.delete(ApiEndpoints.getLeadDetail(id),
            options: _org(organizationId)),
      );

  Future<Response> getAllWorkspaceService(String organizationId) => _safe(
        ApiEndpoints.getAllWorkspace(),
        () => _dioClient.get(ApiEndpoints.getAllWorkspace(),
            options: _org(organizationId)),
      );

  Future<Response> getBusinessProcessService(
          String organizationId, String workspaceId) =>
      _safe(
        ApiEndpoints.getBusinessProcessByWorkspace(workspaceId),
        () => _dioClient.getProducts(
          ApiEndpoints.getBusinessProcessByWorkspace(workspaceId),
          options: _org(organizationId),
        ),
      );

  Future<Response> getBusinessProcessTaskService(
    String organizationId,
    Json? queryParameters, {
    String? taskId,
  }) =>
      _safe(
          taskId != null
              ? '${ApiEndpoints.businessProcessTask()}/$taskId'
              : ApiEndpoints.businessProcessTask(), () {
        final qp = queryParameters == null ? null : _compact(queryParameters);
        return _dioClient.getProducts(
          taskId != null
              ? '${ApiEndpoints.businessProcessTask()}/$taskId'
              : ApiEndpoints.businessProcessTask(),
          options: _org(organizationId),
          queryParameters: qp,
        );
      });

  Future<Response> getListPagingService(
          String organizationId, Map<String, dynamic> data) =>
      _safe(
        ApiEndpoints.getCustomerPaging(),
        () => _dioClient.get(
          ApiEndpoints.getCustomerPaging(),
          options: _org(organizationId),
          queryParameters: _compact(data),
        ),
      );

  Future<Response> getProductService(String organizationId, bool isManage) =>
      _safe(
        ApiEndpoints.product(),
        () => _dioClient.getProducts(ApiEndpoints.product(),
            options: _org(organizationId)),
      );

  Future<Response> getBusinessProcessTemplateService() => _safe(
        ApiEndpoints.businessProcessTemplate(),
        () => _dioClient.getProducts(ApiEndpoints.businessProcessTemplate()),
      );

  Future<Response> getBusinessProcessTagService(
          String organizationId, String workspaceId) =>
      _safe(
        ApiEndpoints.getBusinessProcessTag(),
        () => _dioClient.getProducts(
          ApiEndpoints.getBusinessProcessTag(),
          options: _org(organizationId),
          queryParameters: {'workspaceId': workspaceId},
        ),
      );

  Future<Response> postBusinessProcessTagService(
          String organizationId, Json data) =>
      _safe(
        ApiEndpoints.getBusinessProcessTag(),
        () => _dioClient.postProducts(
          ApiEndpoints.getBusinessProcessTag(),
          options: _org(organizationId),
          data: data,
        ),
      );

  Future<Response> postBusinessProcessTaskService(
          String organizationId, Json data) =>
      _safe(
        ApiEndpoints.businessProcessTask(),
        () => _dioClient.postProducts(ApiEndpoints.businessProcessTask(),
            options: _org(organizationId), data: data),
      );

  Future<Response> linkOrderService(
          String organizationId, String id, Json data) =>
      _safe(
        ApiEndpoints.linkOrder(id),
        () => _dioClient.postProducts(ApiEndpoints.linkOrder(id),
            options: _org(organizationId), data: data),
      );

  Future<Response> postOrderService(String organizationId, Json data) => _safe(
        ApiEndpoints.order(),
        () => _dioClient.postProducts(ApiEndpoints.order(),
            options: _org(organizationId), data: data),
      );

  Future<Response> getDealActivityService(
          String organizationId, String stageId) =>
      _safe(
        ApiEndpoints.businessProcessTask(),
        () => _dioClient.getProducts(
          ApiEndpoints.businessProcessTask(),
          options: _org(organizationId),
          queryParameters: {'stageId': stageId, 'pageSize': 10, 'page': 0},
        ),
      );

  Future<Response> createLeadService(String organizationId, Json data) => _safe(
        ApiEndpoints.createLead(),
        () => _dioClient.post(ApiEndpoints.createLead(),
            options: _org(organizationId), data: data),
      );

  Future<Response> getDetailConversationService(
          String organizationId, String id) =>
      _safe(
        ApiEndpoints.getDetailConversation(id),
        () => _dioClient.get(ApiEndpoints.getDetailConversation(id),
            options: _org(organizationId)),
      );

  Future<Response> getCustomerDetailService(String organizationId, String id,
          {bool isCustomer = false}) =>
      _safe(
        isCustomer
            ? ApiEndpoints.getCustomerDetail(id)
            : ApiEndpoints.getLeadDetail(id),
        () => _dioClient.get(
          isCustomer
              ? ApiEndpoints.getCustomerDetail(id)
              : ApiEndpoints.getLeadDetail(id),
          options: _org(organizationId),
        ),
      );

  Future<Response> updateCustomerService(
          String organizationId, String id, Json data,
          {bool isCustomer = false}) =>
      _safe(
        isCustomer
            ? '${ApiEndpoints.getCustomerDetail(id)}/update-field'
            : '${ApiEndpoints.getLeadDetail(id)}/update-field',
        () => _dioClient.patch(
          isCustomer
              ? '${ApiEndpoints.getCustomerDetail(id)}/update-field'
              : '${ApiEndpoints.getLeadDetail(id)}/update-field',
          options: _org(organizationId),
          data: data,
        ),
      );

  Future<Response> archiveOrderService(
          String organizationId, String conversationId) =>
      _safe(
        ApiEndpoints.archiveOrder(conversationId),
        () => _dioClient.putProducts(
          ApiEndpoints.archiveOrder(conversationId),
          options: _org(organizationId),
        ),
      );

  Future<Response> deleteOrderService(
          String organizationId, String conversationId) =>
      _safe(
        '${ApiEndpoints.businessProcessTask()}/$conversationId',
        () => _dioClient.deleteProducts(
          '${ApiEndpoints.businessProcessTask()}/$conversationId',
          options: _org(organizationId),
        ),
      );

  Future<Response> connectZaloOA(String organizationId, String accessToken) =>
      _safe(
        ApiEndpoints.connectZaloOA(organizationId, accessToken),
        () => _dioClient
            .get(ApiEndpoints.connectZaloOA(organizationId, accessToken)),
      );

  Future<Response> getChannelListService(String organizationId) => _safe(
        ApiEndpoints.getChannelList(),
        () => _dioClient.get(ApiEndpoints.getChannelList(),
            options: _org(organizationId)),
      );

  Future<Response> createWebFormService(String organizationId, Json data) =>
      _safe(
        ApiEndpoints.createWebForm(),
        () => _dioClient.post(ApiEndpoints.createWebForm(),
            options: _org(organizationId), data: data),
      );

  Future<Response> verifyWebFormService(String organizationId, String id) =>
      _safe(
        ApiEndpoints.verifyWebForm(id),
        () => _dioClient.post(ApiEndpoints.verifyWebForm(id),
            options: _org(organizationId)),
      );

  Future<Response> connectChannelService(
          String organizationId, String id, Json data) =>
      _safe(
        ApiEndpoints.connectChannel(id),
        () => _dioClient.patch(ApiEndpoints.connectChannel(id),
            data: data, options: _org(organizationId)),
      );

  Future<Response> disconnectChannelService(
          String organizationId, String id, String provider) =>
      _safe(
        ApiEndpoints.disconnectChannel(id, provider),
        () => _dioClient.delete(ApiEndpoints.disconnectChannel(id, provider),
            options: _org(organizationId)),
      );

  /// gộp với createWebhook (trùng)
  Future<Response> createWebhookService(String organizationId, Json data) =>
      _safe(
        ApiEndpoints.createWebhook(),
        () => _dioClient.post(ApiEndpoints.createWebhook(),
            options: _org(organizationId), data: data),
      );

  // ⛔️ REMOVED: createIntegrationService -> dùng createWebhook()
  // Giữ hàm cũ nếu còn caller, nhưng chuyển hướng tới createWebhook():
  Future<Response> createIntegrationService(String organizationId, Json data) =>
      _safe(
        ApiEndpoints.createWebhook(),
        () => _dioClient.post(ApiEndpoints.createWebhook(),
            options: _org(organizationId), data: data),
      );

  Future<Response> getTiktokLeadConnectionsService(String organizationId) =>
      _safe(
        ApiEndpoints.getTiktokLeadConnections(),
        () => _dioClient.get(ApiEndpoints.getTiktokLeadConnections(),
            options: _org(organizationId)),
      );

  Future<Response> getTiktokItemListService(
    String organizationId,
    String subscribedId,
    bool isConnect,
  ) =>
      _safe(
        ApiEndpoints.getTiktokItemList(
          organizationId: organizationId,
          subscribedId: subscribedId,
          isConnect: isConnect,
        ),
        () => _dioClient.get(
          ApiEndpoints.getTiktokItemList(
            organizationId: organizationId,
            subscribedId: subscribedId,
            isConnect: isConnect,
          ),
          options: _org(organizationId),
        ),
      );

  Future<Response> getTiktokConfigurationService(
          String organizationId, String connectionId, String pageId) =>
      _safe(
        ApiEndpoints.getTiktokConfiguration(
            connectionId: connectionId, pageId: pageId),
        () => _dioClient.get(
          ApiEndpoints.getTiktokConfiguration(
              connectionId: connectionId, pageId: pageId),
          options: _org(organizationId),
        ),
      );

  Future<Response> searchOrganizationService(
          String searchText, String organizationId) =>
      _safe(
        ApiEndpoints.searchOrganization(searchText),
        () => _dioClient.get(
          ApiEndpoints.searchOrganization(searchText),
          queryParameters: const {'limit': 20, 'offset': 0},
          options: _org(organizationId),
        ),
      );

  Future<Response> joinOrganizationService(String organizationId) => _safe(
        ApiEndpoints.joinOrganization(),
        () => _dioClient.post(ApiEndpoints.joinOrganization(),
            options: _org(organizationId)),
      );

  Future<Response> getInvitationListService(
          String organizationId, String type) =>
      _safe(
        ApiEndpoints.getInvitationList(type),
        () => _dioClient.get(ApiEndpoints.getInvitationList(type),
            options: _org(organizationId)),
      );

  Future<Response> getMemberJoinRequestService(
          String organizationId, String type) =>
      _safe(
        ApiEndpoints.getInvitationList(type),
        () => _dioClient.get(ApiEndpoints.getInvitationList(type),
            options: _org(organizationId)),
      );

  Future<Response> acceptInvitationService(String organizationId, String id) =>
      _safe(
        ApiEndpoints.acceptInvitation(id),
        () => _dioClient.post(ApiEndpoints.acceptInvitation(id),
            options: _org(organizationId)),
      );

  Future<Response> rejectInvitationService(String organizationId, String id) =>
      _safe(
        ApiEndpoints.rejectInvitation(id),
        () => _dioClient.post(ApiEndpoints.rejectInvitation(id),
            options: _org(organizationId)),
      );

  Future<Response> linkToLeadService(
          String organizationId, String conversationId, String leadId) =>
      _safe(
        ApiEndpoints.linkToLead(conversationId),
        () => _dioClient.post(ApiEndpoints.linkToLead(conversationId),
            options: _org(organizationId), data: {'leadId': leadId}),
      );
}
