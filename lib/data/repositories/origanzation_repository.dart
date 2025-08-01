import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/error/exceptions.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';

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
        'provider': provider,
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
}
