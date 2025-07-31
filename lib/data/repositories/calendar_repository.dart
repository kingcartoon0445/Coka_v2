import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/data/datasources/remote/api_calendar_service.dart';
import 'package:source_base/data/models/reminder_service_body.dart';

class CalendarRepository {
  final ApiCalendarService apiCalendarService;

  CalendarRepository({required this.apiCalendarService});

  Future<Response> getCalculator(
      String organizationId, String contactId) async {
    try {
      final response = await apiCalendarService.getCalculatorService(
          organizationId, contactId);
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

  Future<Response> updateNoteMark(
      String scheduleId, bool isDone, String notes) async {
    try {
      final response = await apiCalendarService.updateNoteMarkService(
          scheduleId, isDone, notes);
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

  Future<Response> createReminder(
      String organizationId, ReminderServiceBody body) async {
    try {
      final response =
          await apiCalendarService.createReminderService(organizationId, body);
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
