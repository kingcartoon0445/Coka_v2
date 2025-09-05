// ignore_for_file: unnecessary_lambdas

import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/models/reminder_service_body.dart';

typedef Json = Map<String, dynamic>;

class ApiCalendarService {
  final DioClient _dioClient;

  ApiCalendarService(this._dioClient);

  // ------------------------------
  // Helpers
  // ------------------------------

  Options _org(String organizationId) =>
      Options(headers: {'organizationId': organizationId});

  Response<Map<String, dynamic>> _error(String path, Object e,
      {int status = 500, String code = 'unknown_error'}) {
    return Response<Map<String, dynamic>>(
      data: {'success': false, 'error': code, 'message': e.toString()},
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

  // ------------------------------
  // Calendar APIs
  // ------------------------------

  Future<Response> getCalculatorService(
    String organizationId,
    String contactId,
  ) =>
      _safe(
        ApiEndpoints.getCalculator(
          organizationId: organizationId,
          contactId: contactId,
        ),
        () => _dioClient.getCalendar(
          ApiEndpoints.getCalculator(
            organizationId: organizationId,
            contactId: contactId,
          ),
        ),
      );

  Future<Response> updateNoteMarkService(
    String scheduleId,
    bool isDone,
    String notes,
  ) =>
      _safe(
        ApiEndpoints.updateNoteMark(),
        () => _dioClient.patchCalendar(
          ApiEndpoints.updateNoteMark(),
          data: {
            'scheduleId': scheduleId,
            'isDone': isDone,
            if (notes.isNotEmpty) 'notes': notes,
          },
        ),
      );

  Future<Response> createReminderService(
    String organizationId,
    ReminderServiceBody body,
  ) =>
      _safe(
        ApiEndpoints.schedule(),
        () => _dioClient.postCalendar(
          ApiEndpoints.schedule(),
          data: body.toJson(),
        ),
      );

  Future<Response> updateReminderService(
    String organizationId,
    Json data,
  ) =>
      _safe(
        ApiEndpoints.schedule(),
        () => _dioClient.putCalendar(
          ApiEndpoints.schedule(),
          data: data,
          options: _org(organizationId),
        ),
      );

  Future<Response> deleteReminderService(
    String organizationId,
    String reminderId,
  ) =>
      _safe(
        '${ApiEndpoints.schedule()}/$reminderId',
        () => _dioClient.deleteCalendar(
          '${ApiEndpoints.schedule()}/$reminderId',
          options: _org(organizationId),
        ),
      );

  Future<Response> getActivityService(
    String organizationId,
    String workspaceId,
  ) =>
      _safe(
        ApiEndpoints.schedule(),
        () => _dioClient.getCalendar(
          ApiEndpoints.schedule(),
          queryParameters: {
            'organizationId': organizationId,
            'workspaceId': workspaceId,
          },
        ),
      );

  // ------------------------------
  // Business Process / Orders (Products namespace)
  // ------------------------------

  Future<Response> getHistoryService(
    String organizationId,
    String taskId,
  ) =>
      _safe(
        '${ApiEndpoints.businessProcessTask()}/$taskId/notes-simple',
        () => _dioClient.getProducts(
          '${ApiEndpoints.businessProcessTask()}/$taskId/notes-simple',
          options: _org(organizationId),
          queryParameters: {
            'page': 1,
            'pageSize': 20,
            'type': '',
          },
        ),
      );

  Future<Response> updateStageGiveTaskService(
    String organizationId,
    String taskId,
    String newStageId,
  ) =>
      _safe(
        '${ApiEndpoints.businessProcessTask()}/$taskId/move',
        () => _dioClient.putProducts(
          '${ApiEndpoints.businessProcessTask()}/$taskId/move',
          options: _org(organizationId),
          data: {'newStageId': newStageId},
        ),
      );

  Future<Response> updateStatusService(
    String organizationId,
    String taskId,
    bool isSuccess,
  ) =>
      _safe(
        '${ApiEndpoints.businessProcessTask()}/$taskId/status',
        () => _dioClient.putProducts(
          '${ApiEndpoints.businessProcessTask()}/$taskId/status',
          options: _org(organizationId),
          data: {'isSuccess': isSuccess},
        ),
      );

  Future<Response> getOrderDetailWithProduct(
    String organizationId,
    String taskId,
  ) =>
      _safe(
        ApiEndpoints.getOrderDetailWithProduct(taskId),
        () => _dioClient.getProducts(
          ApiEndpoints.getOrderDetailWithProduct(taskId),
          options: _org(organizationId),
        ),
      );

  Future<Response> duplicateOrderService(
    String organizationId,
    String taskId,
  ) =>
      _safe(
        ApiEndpoints.duplicateOrder(taskId),
        () => _dioClient.postProducts(
          ApiEndpoints.duplicateOrder(taskId),
          options: _org(organizationId),
        ),
      );

  Future<Response> archiveOrderService(
    String organizationId,
    String conversationId,
  ) =>
      _safe(
        ApiEndpoints.archiveOrder(conversationId),
        () => _dioClient.putProducts(
          ApiEndpoints.archiveOrder(conversationId),
          options: _org(organizationId),
        ),
      );

  Future<Response> deleteOrderService(
    String organizationId,
    String conversationId,
  ) =>
      _safe(
        '${ApiEndpoints.businessProcessTask()}/$conversationId',
        () => _dioClient.deleteProducts(
          '${ApiEndpoints.businessProcessTask()}/$conversationId',
          options: _org(organizationId),
        ),
      );

  Future<Response> getJourneysService(
    String organizationId,
    String taskId,
    Json data,
  ) =>
      _safe(
        ApiEndpoints.journeys(taskId),
        () => _dioClient.postProducts(
          ApiEndpoints.journeys(taskId),
          options: _org(organizationId),
          data: data,
        ),
      );
}
