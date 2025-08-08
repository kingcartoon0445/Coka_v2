import 'package:dio/dio.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';

class FinalDealRepository {
  final ApiService apiService;

  FinalDealRepository({required this.apiService});

  Future<Response> getAllWorkspace(String organizationId) async {
    return await apiService.getAllWorkspaceService(organizationId);
  }

  Future<Response> getBusinessProcess(
      String organizationId, String workspaceId) async {
    return await apiService.getBusinessProcessService(
        organizationId, workspaceId);
  }

  Future<Response> getBusinessProcessTask(
    String organizationId,
    String workspaceId,
    String processId,
    String stageId,
    String customerId,
    String assignedTo,
    String status,
    bool includeHistory,
    int page,
    int pageSize,
  ) async {
    return await apiService.getBusinessProcessTaskService(organizationId, {
      'workspaceId': workspaceId,
      'processId': processId,
      'stageId': stageId,
      'customerId': customerId,
      'assignedTo': assignedTo,
      'status': status,
      'includeHistory': includeHistory,
      'page': page,
      'pageSize': pageSize,
    });
  }
}
