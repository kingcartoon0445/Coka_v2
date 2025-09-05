import 'package:dio/dio.dart';
import 'package:source_base/core/api/api_endpoints.dart';
import 'package:source_base/data/datasources/remote/api_calendar_service.dart';
import 'package:source_base/data/models/reminder_service_body.dart';

typedef Json = Map<String, dynamic>;

class CalendarRepository {
  final ApiCalendarService apiCalendarService;

  CalendarRepository({required this.apiCalendarService});

  // ------------------------------
  // Helpers
  // ------------------------------

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
  // Repository methods
  // ------------------------------

  Future<Response> getCalculator(String organizationId, String contactId) {
    final path = ApiEndpoints.getCalculator(
      organizationId: organizationId,
      contactId: contactId,
    );
    return _safe(path, () {
      return apiCalendarService.getCalculatorService(organizationId, contactId);
    });
  }

  Future<Response> updateNoteMark(
      String scheduleId, bool isDone, String notes) {
    final path = ApiEndpoints.updateNoteMark();
    return _safe(path, () {
      return apiCalendarService.updateNoteMarkService(
          scheduleId, isDone, notes);
    });
  }

  Future<Response> createReminder(
      String organizationId, ReminderServiceBody body) {
    final path = ApiEndpoints.schedule();
    return _safe(path, () {
      return apiCalendarService.createReminderService(organizationId, body);
    });
  }

  Future<Response> updateReminder(
      String organizationId, ReminderServiceBody data) {
    final path = ApiEndpoints.schedule();
    return _safe(path, () {
      return apiCalendarService.updateReminderService(
          organizationId, data.toJson());
    });
  }

  Future<Response> deleteReminder(String organizationId, String reminderId) {
    final path = '${ApiEndpoints.schedule()}/$reminderId';
    return _safe(path, () {
      return apiCalendarService.deleteReminderService(
          organizationId, reminderId);
    });
  }
}
