import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/error/exceptions.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/filter_item/model/create_model.dart';

class OrganizationRepository {
  final ApiService apiService;

  OrganizationRepository({required this.apiService});

  Future<Response> getOrganizations({
    required String limit,
    required String offset,
    required String searchText,
  }) async {
    try {
      final res = await apiService.getOrganizationsService(
        limit: limit,
        offset: offset,
        searchText: searchText,
      );
      return res;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi lấy danh sách tổ chức',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> getOrganizationDetail(String organizationId) async {
    try {
      // Theo code cũ: gọi user info
      final res = await apiService.getUserInfoService();
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.profileDetail()),
      );
    }
  }

  Future<Response> getCustomerService(
    String organizationId,
    LeadPagingRequest pagingRequest,
  ) async {
    try {
      final res = await apiService.getCustomerService(
        organizationId,
        pagingRequest: pagingRequest,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getLeadPaging()),
      );
    }
  }

  Future<Response> getLeadPagingArchive(
    String id,
    String organizationId, {
    int? limit,
    int? offset,
    String? type,
  }) async {
    try {
      final res = await apiService.getJourneyPagingService(
        id,
        organizationId,
        limit: limit,
        offset: offset,
        type: type,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getJourneyPaging(id)),
      );
    }
  }

  Future<Response> getFilterItem(String organizationId) async {
    try {
      final res = await apiService.getListPaging(organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getlistpagingTags()),
      );
    }
  }

  Future<Response> getListMember(String organizationId) async {
    try {
      final res = await apiService.getListMember(organizationId);
      return res;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> getUtmSource(String organizationId) async {
    try {
      final res = await apiService.getUtmSource(organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getUtmSource()),
      );
    }
  }

  Future<Response> postCustomerNote(
    String customerId,
    String note,
    String organizationId,
  ) async {
    try {
      final res = await apiService.postCustomerNoteService(
        customerId,
        note,
        organizationId,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.postCustomerNote(customerId)),
      );
    }
  }

  Future<Response> getFacebookChatPaging(
    String organizationId,
    int limit,
    int offset,
    String provider,
  ) async {
    try {
      final res = await apiService.getCustomerService(
        organizationId,
        pagingRequest: LeadPagingRequest(
          channels: [provider],
          offset: offset,
          limit: limit,
        ),
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getLeadPaging()),
      );
    }
  }

  Future<Response> postStorageConvertToCustomer(
    String customerId,
    String organizationId,
  ) async {
    try {
      final res = await apiService.postArchiveCustomerService(
        customerId,
        organizationId,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.postArchiveCustomer(customerId)),
      );
    }
  }

  Future<Response> postUnArchiveCustomer(
    String id,
    String organizationId,
  ) async {
    try {
      final res =
          await apiService.postUnArchiveCustomerService(id, organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.postUnArchiveCustomer(id)),
      );
    }
  }

  Future<Response> updateStatusRead(
    String conversationId,
    String organizationId,
  ) async {
    try {
      final res = await apiService.updateStatusReadService(
        conversationId,
        organizationId,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.updateStatusRead(conversationId)),
      );
    }
  }

  Future<Response> deleteCustomerService(
    String id,
    String organizationId,
  ) async {
    try {
      final res = await apiService.deleteCustomerService(id, organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getLeadDetail(id)),
      );
    }
  }

  Future<Response> createLead(
    String organizationId,
    CreateLeadModel data,
  ) async {
    try {
      final res = await apiService.createLeadService(
        organizationId,
        data.toJson(),
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.createLead()),
      );
    }
  }

  Future<Response> getChannelList(String organizationId) async {
    try {
      final res = await apiService.getChannelListService(organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getChannelList()),
      );
    }
  }

  Future<Response> createWebForm(
    String organizationId,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await apiService.createWebFormService(organizationId, data);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.createWebForm()),
      );
    }
  }

  Future<Response> verifyWebForm(String organizationId, String id) async {
    try {
      final res = await apiService.verifyWebFormService(organizationId, id);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.verifyWebForm(id)),
      );
    }
  }

  Future<Response> connectChannel(
    String organizationId,
    String id,
    int status,
    String provider,
  ) async {
    try {
      final res = await apiService.connectChannelService(
        organizationId,
        id,
        {'status': status, 'provider': provider},
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.connectChannel(id)),
      );
    }
  }

  Future<Response> disconnectChannel(
    String organizationId,
    String id,
    String provider,
  ) async {
    try {
      final res = await apiService.disconnectChannelService(
          organizationId, id, provider);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.disconnectChannel(id, provider)),
      );
    }
  }

  /// API mới gộp createIntegration -> createWebhook
  Future<Response> createIntegration(
    String organizationId,
    String source,
    String expiryDate,
  ) async {
    try {
      final res = await apiService.createWebhookService(organizationId, {
        'title': 'Webhook',
        'source': source,
        'expiryDate': expiryDate,
      });
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.createWebhook()),
      );
    }
  }

  Future<Response> getTiktokLeadConnections(String organizationId) async {
    try {
      final res =
          await apiService.getTiktokLeadConnectionsService(organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.getTiktokLeadConnections()),
      );
    }
  }

  Future<Response> getTiktokItemList(
    String organizationId,
    String subscribedId,
    bool isConnect, // đổi sang bool
  ) async {
    try {
      final res = await apiService.getTiktokItemListService(
        organizationId,
        subscribedId,
        isConnect,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(
          path: ApiEndpoints.getTiktokItemList(
            organizationId: organizationId,
            subscribedId: subscribedId,
            isConnect: isConnect,
          ),
        ),
      );
    }
  }

  Future<Response> getTiktokConfiguration(
    String organizationId,
    String connectionId,
    String pageId,
  ) async {
    try {
      final res = await apiService.getTiktokConfigurationService(
        organizationId,
        connectionId,
        pageId,
      );
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(
          path: ApiEndpoints.getTiktokConfiguration(
            connectionId: connectionId,
            pageId: pageId,
          ),
        ),
      );
    }
  }

  Future<Response> searchOrganization(
    String searchText,
    String organizationId,
  ) async {
    try {
      final res = await apiService.searchOrganizationService(
          searchText, organizationId);
      return res;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString()
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.searchOrganization(searchText)),
      );
    }
  }

  Future<Response> joinOrganization(String organizationId) async {
    try {
      final res = await apiService.joinOrganizationService(organizationId);
      if (res.statusCode == 200) {
        return res;
      }
      throw ServerException(
        message: res.data['message'],
        statusCode: res.statusCode ?? 0,
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> getInvitationList(String organizationId, String type) async {
    try {
      final res =
          await apiService.getInvitationListService(organizationId, type);
      return res;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> acceptInvitation(String organizationId, String id) async {
    try {
      final res = await apiService.acceptInvitationService(organizationId, id);
      return res;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> linkToLeadRepository(
    String organizationId,
    String conversationId,
    String leadId,
  ) async {
    try {
      final res = await apiService.linkToLeadService(
        organizationId,
        conversationId,
        leadId,
      );
      return res;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi liên kết đến lead',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> rejectInvitation(String organizationId, String id) async {
    try {
      final res = await apiService.rejectInvitationService(organizationId, id);
      return res;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
