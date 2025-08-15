import 'package:dio/dio.dart';
import 'package:source_base/data/datasources/remote/api_calendar_service.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';

class DealActivityRepository {
  final ApiService apiService;
  final ApiCalendarService apiCalendarService;

  DealActivityRepository(
      {required this.apiService, required this.apiCalendarService});
  Future<Response> getDealActivity(
      String organizationId, String stageId) async {
    return await apiService.getDealActivityService(organizationId, stageId);
  }

  Future<Response> getHistory(String organizationId, String taskId) async {
    return await apiCalendarService.getHistoryService(organizationId, taskId);
  }

  Future<Response> getActivity(
      String organizationId, String workspaceId) async {
    return await apiCalendarService.getActivityService(
        organizationId, workspaceId);
  }

  Future<Response> updateStageGiveTask(
      String organizationId, String taskId, String newStageId) async {
    return await apiCalendarService.updateStageGiveTaskService(
        organizationId, taskId, newStageId);
  }

  Future<Response> updateStatus(
      String organizationId, String taskId, bool isSuccess) async {
    return await apiCalendarService.updateStatusService(
        organizationId, taskId, isSuccess);
  }

  Future<Response> getDetailTask(String organizationId, String taskId) async {
    return await apiService.getBusinessProcessTaskService(
        organizationId, null, taskId: taskId);
  }

  Future<Response> getOrderDetailWithProduct(
      String organizationId, String taskId) async {
    return await apiCalendarService.getOrderDetailWithProduct(
        organizationId, taskId);
  }
}
