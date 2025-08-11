import 'package:dio/dio.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:source_base/data/repositories/model_switch/business_process_data.dart';
import 'package:source_base/data/repositories/model_switch/order_data.dart';

class SwitchFinalDealRepository {
  final ApiService apiService;

  SwitchFinalDealRepository({required this.apiService});

  Future<Response> getListPaging({
    required String organizationId,
    required int limit,
    required int offset,
    required String startDate,
    required String endDate,
    required bool isBusiness,
    required String searchText,
  }) async {
    return await apiService.getListPagingService(organizationId, {
      "limit": limit,
      "offset": offset,
      "startDate": startDate,
      "endDate": endDate,
      "isBusiness": isBusiness,
      "searchText": searchText
    });
  }

  Future<Response> getProduct(String organizationId, bool isManage) async {
    return await apiService.getProductService(organizationId, isManage);
  }

  Future<Response> getBusinessProcessTemplate() async {
    return await apiService.getBusinessProcessTemplateService();
  }

  Future<Response> getBusinessProcessTag(
      String organizationId, String workspaceId) async {
    return await apiService.getBusinessProcessTagService(
        organizationId, workspaceId);
  }

  Future<Response> postBusinessProcessTag(String organizationId, String name,
      String backgroundColor, String textColor, String workspaceId) async {
    return await apiService.postBusinessProcessTagService(organizationId, {
      "backgroundColor": backgroundColor,
      "name": name,
      "textColor": textColor,
      "workspaceId": workspaceId,
    });
  }

  Future<Response> postBusinessProcessTagService(
      String organizationId, TaskData taskData) async {
    return await apiService.postBusinessProcessTagService(
        organizationId, taskData.toJson());
  }

  Future<Response> postBusinessProcessTask(
      String organizationId, TaskData taskData) async {
    return await apiService.postBusinessProcessTaskService(
        organizationId, taskData.toJson());
  }

  Future<Response> postOrder(String organizationId, OrderData orderData) async {
    return await apiService.postOrderService(
        organizationId, orderData.toJson());
  }

  Future<Response> linkOrder(
    String organizationId,
    String id,
    String orderId,
  ) async {
    return await apiService.linkOrderService(organizationId, id, {
      "orderId": orderId,
    });
  }
}
