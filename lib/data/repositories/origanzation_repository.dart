import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/error/exceptions.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/filter_item/model/create_model.dart';

class OrganizationRepository {
  final ApiService apiService;

  OrganizationRepository({required this.apiService});

  Future<Response> getOrganizations(
      {required String limit,
      required String offset,
      required String searchText}) async {
    try {
      final response = await apiService.getOrganizationsService(
          limit: limit, offset: offset, searchText: searchText);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi đăng nhập Google',
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Response> getOrganizationDetail(String organizationId) async {
    try {
      final response = await apiService.getUserInfoService();
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> getCustomerService(
      String organizationId, LeadPagingRequest pagingRequest) async {
    try {
      final response = await apiService.getCustomerService(organizationId,
          pagingRequest: pagingRequest);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
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
      final response = await apiService.getJourneyPagingService(
          id, organizationId,
          limit: limit, offset: offset, type: type);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> getFilterItem(String organizationId) async {
    try {
      final response = await apiService.getListPaging(organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> getListMember(String organizationId) async {
    try {
      final response = await apiService.getListMember(organizationId);
      return response;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> getUtmSource(String organizationId) async {
    try {
      final response = await apiService.getUtmSource(organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> postCustomerNote(
      String customerId, String note, String organizationId) async {
    try {
      final response = await apiService.postCustomerNoteService(
          customerId, note, organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.postCustomerNote(customerId)),
      );
    }
  }

  Future<Response> getFacebookChatPaging(
      String organizationId, int limit, int offset, String provider) async {
    try {
      final response =
          await apiService.getConversationListService(organizationId, {
        'channels': provider,
        'offset': offset,
        'limit': limit,
        'sort': '[{ Column: "CreatedDate", Dir: "DESC" }]',
      });
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> postStorageConvertToCustomer(
      String customerId, String organizationId) async {
    try {
      final response = await apiService.postArchiveCustomerService(
          customerId, organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> postUnArchiveCustomer(
      String id, String organizationId) async {
    try {
      final response =
          await apiService.postUnArchiveCustomerService(id, organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> updateStatusRead(
      String conversationId, String organizationId) async {
    try {
      final response = await apiService.updateStatusReadService(
          conversationId, organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> deleteCustomerService(
      String id, String organizationId) async {
    try {
      final response =
          await apiService.deleteCustomerService(id, organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> createLead(
      String organizationId, CreateLeadModel data) async {
    try {
      final response =
          await apiService.createLeadService(organizationId, data.toJson());
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.createLead),
      );
    }
  }

  Future<Response> getChannelList(String organizationId) async {
    try {
      final response = await apiService.getChannelListService(organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.getChannelList),
      );
    }
  }

  Future<Response> createWebForm(
      String organizationId, Map<String, dynamic> data) async {
    try {
      final response =
          await apiService.createWebFormService(organizationId, data);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.createWebForm),
      );
    }
  }

  Future<Response> verifyWebForm(String organizationId, String id) async {
    try {
      final response =
          await apiService.verifyWebFormService(organizationId, id);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.verifyWebForm(id)),
      );
    }
  }

  Future<Response> connectChannel(
      String organizationId, String id, int status, String provider) async {
    try {
      final response = await apiService.connectChannelService(
          organizationId, id, {"status": status, "provider": provider});
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.connectChannel(id)),
      );
    }
  }

  Future<Response> disconnectChannel(
      String organizationId, String id, String provider) async {
    try {
      final response = await apiService.disconnectChannelService(
          organizationId, id, provider);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.disconnectChannel(id, provider)),
      );
    }
  }

  Future<Response> createIntegration(
      String organizationId, String source, String expiryDate) async {
    try {
      final response =
          await apiService.createIntegrationService(organizationId, {
        "title": "Webhook",
        "source": source,
        "expiryDate": expiryDate,
      });
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ''),
      );
    }
  }

  Future<Response> getTiktokLeadConnections(String organizationId) async {
    try {
      final response =
          await apiService.getTiktokLeadConnectionsService(organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions:
            RequestOptions(path: ApiEndpoints.getTiktokLeadConnections),
      );
    }
  }

  Future<Response> getTiktokItemList(
      String organizationId, String subscribedId, String isConnect) async {
    try {
      final response = await apiService.getTiktokItemListService(
          organizationId, subscribedId, isConnect);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(
            path: ApiEndpoints.getTiktokItemList(
                organizationId, subscribedId, isConnect)),
      );
    }
  }

  Future<Response> getTiktokConfiguration(
      String organizationId, String connectionId, String pageId) async {
    try {
      final response = await apiService.getTiktokConfigurationService(
          organizationId, connectionId, pageId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(
            path: ApiEndpoints.getTiktokConfiguration(connectionId, pageId)),
      );
    }
  }

  Future<Response> searchOrganization(
      String searchText, String organizationId) async {
    try {
      final response = await apiService.searchOrganizationService(
          searchText, organizationId);
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
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
      final response = await apiService.joinOrganizationService(organizationId);
      if (response.statusCode == 200) {
        return response;
      } else {
        throw ServerException(
            message: response.data['message'],
            statusCode: response.statusCode ?? 0);
      }
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> getInvitationList(String organizationId, String type) async {
    try {
      final response =
          await apiService.getInvitationListService(organizationId, type);
      return response;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> acceptInvitation(String organizationId, String id) async {
    try {
      final response =
          await apiService.acceptInvitationService(organizationId, id);
      return response;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Response> rejectInvitation(String organizationId, String id) async {
    try {
      final response =
          await apiService.rejectInvitationService(organizationId, id);
      return response;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
