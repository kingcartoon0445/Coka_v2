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
        requestOptions: RequestOptions(path: ApiEndpoints.login),
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
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }

  Future<Response> createReminderService(
      String organizationId, ReminderServiceBody body) async {
    try {
      final response = await _dioClient.postCalendar(
        ApiEndpoints.createReminder,
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
        requestOptions: RequestOptions(path: ApiEndpoints.login),
      );
    }
  }
}
