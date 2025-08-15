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
    String processId,
    String stageId,
    String customerId,
    String assignedTo,
    String status,
    bool includeHistory,
    int page,
    int pageSize, {
    String? taskId,
  }) async {
    return await apiService.getBusinessProcessTaskService(
        organizationId,
        taskId != null
            ? null
            : {
                'stageId': stageId,
                'processId': processId,
                'customerId': customerId,
                'assignedTo': assignedTo,
                'status': status,
                'includeHistory': includeHistory,
                'page': page,
                'pageSize': pageSize,
              },
        taskId: taskId);
  }
}
