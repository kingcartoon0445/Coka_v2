import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/models/reminder_service_body.dart';

class ApiCalendarService {
  final DioClient _dioClient;

  ApiCalendarService(this._dioClient);

  Future<Response> getCalculatorService(
      String organizationId, String contactId) async {
    try {
      final response = await _dioClient
          .getCalendar(ApiEndpoints.getCalculator(organizationId, contactId));
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
            path: ApiEndpoints.getCalculator(organizationId, contactId)),
      );
    }
  }

  Future<Response> updateNoteMarkService(
      String scheduleId, bool isDone, String notes) async {
    try {
      final response = await _dioClient.patchCalendar(
        ApiEndpoints.updateNoteMark,
        data: {
          'scheduleId': scheduleId,
          'isDone': isDone,
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
        requestOptions: RequestOptions(path: ApiEndpoints.updateNoteMark),
      );
    }
  }

  Future<Response> createReminderService(
      String organizationId, ReminderServiceBody body) async {
    try {
      final response = await _dioClient.postCalendar(
        ApiEndpoints.schedule,
        data: body.toJson(),
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
        requestOptions: RequestOptions(path: ApiEndpoints.schedule),
      );
    }
  }

  Future<Response> updateReminderService(
      String organizationId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.putCalendar(ApiEndpoints.schedule,
          data: data,
          options: Options(
            headers: {
              'organizationId': organizationId,
            },
          ));
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
        requestOptions: RequestOptions(path: ApiEndpoints.schedule),
      );
    }
  }

  Future<Response> deleteReminderService(
      String organizationId, String reminderId) async {
    try {
      final response = await _dioClient.deleteCalendar(
        '${ApiEndpoints.schedule}/$reminderId',
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
        requestOptions: RequestOptions(path: ApiEndpoints.schedule),
      );
    }
  }

  Future<Response> getActivityService(
      String organizationId, String workspaceId) async {
    try {
      final response =
          await _dioClient.getCalendar(ApiEndpoints.schedule, queryParameters: {
        'organizationId': organizationId,
        'workspaceId': workspaceId,
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
        requestOptions: RequestOptions(path: ApiEndpoints.schedule),
      );
    }
  }

  Future<Response> getHistoryService(
      String organizationId, String taskId) async {
    try {
      final response = await _dioClient.getProducts(
          "${ApiEndpoints.businessProcessTask}/$taskId/notes-simple",
          options: Options(headers: {'organizationid': organizationId}),
          queryParameters: {
            'page': 1,
            'pageSize': 20,
            'type': '',
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

  Future<Response> updateStageGiveTaskService(
      String organizationId, String taskId, String newStageId) async {
    try {
      final response = await _dioClient.putProducts(
          "${ApiEndpoints.businessProcessTask}/$taskId/move",
          options: Options(headers: {'organizationid': organizationId}),
          data: {
            'newStageId': newStageId,
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

  Future<Response> updateStatusService(
      String organizationId, String taskId, bool isSuccess) async {
    try {
      final response = await _dioClient.putProducts(
          "${ApiEndpoints.businessProcessTask}/$taskId/status",
          options: Options(headers: {'organizationid': organizationId}),
          data: {'isSuccess': isSuccess});
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

  Future<Response> getOrderDetailWithProduct(
      String organizationId, String taskId) async {
    try {
      final response = await _dioClient.getProducts(
          ApiEndpoints.getOrderDetailWithProduct(taskId),
          options: Options(headers: {'organizationid': organizationId}));
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
            path: ApiEndpoints.getOrderDetailWithProduct(taskId)),
      );
    }
  }

  Future<Response> duplicateOrderService(
    String organizationId,
    String taskId,
  ) async {
    try {
      final response = await _dioClient.postProducts(
        ApiEndpoints.duplicateOrder(taskId),
        options: Options(headers: {'organizationid': organizationId}),
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
            RequestOptions(path: ApiEndpoints.duplicateOrder(taskId)),
      );
    }
  }

  Future<Response> archiveOrderService(
      String organizationId, String conversationId) async {
    try {
      final response = await _dioClient.putProducts(
          ApiEndpoints.archiveOrder(conversationId),
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
            RequestOptions(path: ApiEndpoints.archiveOrder(conversationId)),
      );
    }
  }

  Future<Response> deleteOrderService(
      String organizationId, String conversationId) async {
    try {
      final response = await _dioClient.deleteProducts(
          '${ApiEndpoints.businessProcessTask}/$conversationId',
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
            RequestOptions(path: ApiEndpoints.archiveOrder(conversationId)),
      );
    }
  }

  Future<Response> getJourneysService(
      String organizationId, String taskId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.postProducts(
          ApiEndpoints.journeys(taskId),
          options: Options(headers: {'organizationid': organizationId}),
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
        requestOptions: RequestOptions(path: ApiEndpoints.journeys(taskId)),
      );
    }
  }
}
