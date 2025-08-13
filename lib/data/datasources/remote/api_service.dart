import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart'
    show LeadPagingRequest;
import 'package:source_base/dio/service_locator.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart' show MediaType;

class ApiService {
  final DioClient _dioClient;
  final SharedPreferencesService _prefsService =
      getIt<SharedPreferencesService>();

  ApiService(this._dioClient);

  // Phương thức đăng nhập
  Future<Response> loginService(String email) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'userName': email,
        },
      );
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

  Future<Response> verifyOTPService(
      {required String otpId, required String otpCode}) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'otpId': otpId,
          'code': otpCode,
        },
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.verifyOtp),
      );
    }
  }

  Future<Response> reSendOtpService(String otpID) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.resendOtp,
        data: {
          'otpId': otpID,
        },
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.resendOtp),
      );
    }
  }

  Future<Response> getUserInfoService() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.profileDetail);
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
        requestOptions: RequestOptions(path: ApiEndpoints.profileDetail),
      );
    }
  }

  Future<Response> updateProfileService(
    Map<String, dynamic> data, {
    File? avatar,
  }) async {
    try {
      final formData = FormData();

      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      if (avatar != null) {
        final fileName = avatar.path.split('/').last;
        final mimeType = fileName.endsWith('.png')
            ? 'image/png'
            : fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')
                ? 'image/jpeg'
                : 'image/jpg';

        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            avatar.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        ));
      }

      // return await _apiClient.patch(
      //   ApiPath.profileUpdate,
      //   data: formData,
      // );

      Response response = await _dioClient.patch(
        ApiEndpoints.profileUpdate,
        data: formData,
      );

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
        requestOptions: RequestOptions(path: '/login/google'),
      );
    }
  }

  Future<Response> loginWithGoogle({bool forceNewAccount = false}) async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      forceCodeForRefreshToken: true,
    );

    if (forceNewAccount) {
      await googleSignIn.signOut();
    }

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Đăng nhập Google bị hủy');

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      if (accessToken == null) throw Exception('Không thể lấy token Google');

      return await socialLogin(accessToken, 'google');
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: '/login/google'),
      );
    }
  }

  Future<Response> loginWithFacebook({bool forceNewAccount = false}) async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['pages_show_list'],
      );
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken?.tokenString;
        if (accessToken == null) {
          throw Exception('Không thể lấy token Facebook');
        }
        return await socialLogin(accessToken, 'facebook');
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Đăng nhập Facebook bị hủy');
      } else {
        throw Exception('Đăng nhập Facebook thất bại');
      }
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: '/login/facebook'),
      );
    }
  }

  Future<Response> socialLogin(String accessToken, String provider) async {
    try {
      return await _dioClient.post(
        ApiEndpoints.socialLogin,
        data: {
          'accessToken': accessToken,
          'provider': provider,
        },
      );
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.socialLogin),
      );
    }
  }

  Future<Response> getOrganizationsService(
      {required String limit,
      required String offset,
      required String searchText}) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        'searchText': searchText,
      };
      return await _dioClient.get(ApiEndpoints.organizationPaging,
          queryParameters: queryParams);
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.organizationPaging),
      );
    }
  }

  Future<Response> getCustomerService(
    String organizationId, {
    required LeadPagingRequest pagingRequest,
    // List<CustomCondition> customConditions = const [],
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.getLeadPaging,
        data: pagingRequest.toJson(),
        options: Options(headers: {
          'organizationId': organizationId,
        }),
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getLeadPaging),
      );
    }
  }

  Future<Response> getJourneyPagingService(String id, String organizationId,
      {int? limit, int? offset, String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (type != null) queryParams['type'] = type;
      final response = await _dioClient.get(
        ApiEndpoints.getJourneyPaging(id),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'organizationId': organizationId,
          },
        ),
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getJourneyPaging(id)),
      );
    }
  }

  Future<Response> getUtmSource(String organizationId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getUtmSource,
        options: Options(headers: {'organizationId': organizationId}),
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getUtmSource),
      );
    }
  }

  Future<Response> getListPaging(String organizationId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getlistpaging,
        options: Options(headers: {'organizationId': organizationId}),
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getlistpaging),
      );
    }
  }

  Future<Response> getListMember(String organizationId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getListMember,
        options: Options(headers: {'organizationId': organizationId}),
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getlistpaging),
      );
    }
  }

  Future<Response> getOrganizationDetailService(String organizationId) async {
    try {
      return await _dioClient.get(
        '${ApiEndpoints.organizationDetail}/$organizationId',
      );
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'unknown_error',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Unknown error',
        requestOptions: RequestOptions(path: ApiEndpoints.organizationDetail),
      );
    }
  }

  Future<Response> refreshTokenService(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
        },
      );
      return response;
    } catch (e) {
      return Response<Map<String, dynamic>>(
        data: {
          'success': false,
          'error': 'refresh_token_failed',
          'message': e.toString(),
        },
        statusCode: 500,
        statusMessage: 'Refresh token failed',
        requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
      );
    }
  }

  Future<Response> postCustomerNoteService(
      String customerId, String note, String organizationId) async {
    try {
      final response = await _dioClient.post(
          ApiEndpoints.postCustomerNote(customerId),
          options: Options(headers: {'organizationId': organizationId}),
          data: {'note': note});
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

  Future<Response> postArchiveCustomerService(
      String id, String organizationId) async {
    try {
      final response = await _dioClient.post(
          ApiEndpoints.postArchiveCustomer(id),
          options: Options(headers: {'organizationId': organizationId}));
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
            RequestOptions(path: ApiEndpoints.postArchiveCustomer(id)),
      );
    }
  }

  Future<Response> postUnArchiveCustomerService(
      String id, String organizationId) async {
    try {
      final response = await _dioClient.post(
          ApiEndpoints.postUnArchiveCustomer(id),
          options: Options(headers: {'organizationId': organizationId}));
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
            RequestOptions(path: ApiEndpoints.postUnArchiveCustomer(id)),
      );
    }
  }

  Future<Response> getConversationListService(
      String organizationId, Map<String, dynamic>? queryParameters) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getLeadPaging,
        options: Options(headers: {'organizationId': organizationId}),
        queryParameters: queryParameters,
      );

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
        requestOptions: RequestOptions(path: ApiEndpoints.conversationList),
      );
    }
  }

  Future<Response> getChatListService(String organizationId,
      String conversationId, int limit, int offset) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.chatList,
        options: Options(headers: {'organizationId': organizationId}),
        queryParameters: {
          'conversationId': conversationId,
          'limit': limit,
          'offset': offset,
        },
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.chatList),
      );
    }
  }
  // Future<Response> getUserInfoService(String organizationId) async {
  //   return await _dioClient.get('${ApiEndpoints.profileDetail}');
  // }

  Future<Response> updateStatusReadService(
      String conversationId, String organizationId) async {
    try {
      final response = await _dioClient.patch(
        ApiEndpoints.updateStatusRead(conversationId),
        options: Options(headers: {'organizationId': organizationId}),
      );
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
            RequestOptions(path: ApiEndpoints.updateStatusRead(conversationId)),
      );
    }
  }

  Future<Response> sendMessageService(
      String organizationId, String conversationId, FormData formData) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.sendMessage,
          options: Options(headers: {'organizationid': organizationId}),
          data: formData);
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
        requestOptions: RequestOptions(path: ApiEndpoints.sendMessage),
      );
    }
  }

  Future<Response> sendImageMessageService(
      String organizationId, FormData formData) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.sendMessage,
          options: Options(headers: {'organizationid': organizationId}),
          data: formData);
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
        requestOptions: RequestOptions(path: ApiEndpoints.sendMessage),
      );
    }
  }

  Future<Response> deleteCustomerService(
      String id, String organizationId) async {
    try {
      final response = await _dioClient.delete(ApiEndpoints.customerPath(id),
          options: Options(headers: {'organizationId': organizationId}));
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
        requestOptions: RequestOptions(path: ApiEndpoints.customerPath(id)),
      );
    }
  }

  Future<Response> getAllWorkspaceService(String organizationId) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.getAllWorkspace,
          options: Options(headers: {'organizationId': organizationId}));
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
        requestOptions: RequestOptions(path: ApiEndpoints.getAllWorkspace),
      );
    }
  }

  Future<Response> getBusinessProcessService(
      String organizationId, String workspaceId) async {
    try {
      final response = await _dioClient.getProducts(
        ApiEndpoints.getBusinessProcess(workspaceId),
        options: Options(headers: {'organizationId': organizationId}),
      );
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
            RequestOptions(path: ApiEndpoints.getBusinessProcess(workspaceId)),
      );
    }
  }

  Future<Response> getBusinessProcessTaskService(
      String organizationId, Map<String, dynamic>? queryParameters) async {
    try {
      // XOÁ KEY CÓ VALUE =''
      if (queryParameters != null) {
        queryParameters.removeWhere((key, value) => value == '');
      }
      final response = await _dioClient.getProducts(
          ApiEndpoints.getBusinessProcessTask,
          options: Options(headers: {'organizationId': organizationId}),
          queryParameters: queryParameters);
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
            RequestOptions(path: ApiEndpoints.getBusinessProcessTask),
      );
    }
  }

  Future<Response> getListPagingService(
      String organizationId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getCustomerPaging,
        options: Options(headers: {'organizationId': organizationId}),
        queryParameters: data,
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getCustomerPaging),
      );
    }
  }

  Future<Response> getProductService(
      String organizationId, bool isManage) async {
    try {
      final response = await _dioClient.getProducts(ApiEndpoints.getProduct,
          options: Options(headers: {'organizationId': organizationId}));
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
        requestOptions: RequestOptions(path: ApiEndpoints.getProduct),
      );
    }
  }

  Future<Response> getBusinessProcessTemplateService() async {
    try {
      final response = await _dioClient.getProducts(
        ApiEndpoints.businessProcessTemplate,
      );
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
        requestOptions: RequestOptions(path: ApiEndpoints.getProduct),
      );
    }
  }

  Future<Response> getBusinessProcessTagService(
      String organizationId, String workspaceId) async {
    try {
      final response = await _dioClient.getProducts(
          ApiEndpoints.getBusinessProcessTag,
          options: Options(headers: {'organizationId': organizationId}),
          queryParameters: {'workspaceId': workspaceId});
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
            RequestOptions(path: ApiEndpoints.getBusinessProcessTag),
      );
    }
  }

  Future<Response> postBusinessProcessTagService(
      String organizationId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.postProducts(
          ApiEndpoints.getBusinessProcessTag,
          options: Options(headers: {'organizationId': organizationId}),
          data: data);
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
        requestOptions: RequestOptions(path: ApiEndpoints.getProduct),
      );
    }
  }

  Future<Response> postBusinessProcessTaskService(
      String organizationId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.postProducts(
          ApiEndpoints.businessProcessTask,
          options: Options(headers: {'organizationId': organizationId}),
          data: data);
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
        requestOptions: RequestOptions(path: ApiEndpoints.businessProcessTask),
      );
    }
  }

  Future<Response> linkOrderService(
      String organizationId, String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.postProducts(ApiEndpoints.linkOrder(id),
          options: Options(headers: {'organizationId': organizationId}),
          data: data);
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
        requestOptions: RequestOptions(path: ApiEndpoints.linkOrder(id)),
      );
    }
  }

  Future<Response> postOrderService(
      String organizationId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.postProducts(ApiEndpoints.order,
          options: Options(headers: {'organizationId': organizationId}),
          data: data);
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
            RequestOptions(path: ApiEndpoints.getBusinessProcessTag),
      );
    }
  }

  Future<Response> getDealActivityService(
      String organizationId, String stageId) async {
    try {
      final response = await _dioClient.getProducts(
          ApiEndpoints.businessProcessTask,
          options: Options(headers: {'organizationId': organizationId}),
          queryParameters: {
            'stageId': stageId,
            'pageSize': 10,
            'page': 0,
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
        requestOptions: RequestOptions(path: ApiEndpoints.businessProcessTask),
      );
    }
  }
}
