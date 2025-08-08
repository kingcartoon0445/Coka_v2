import 'package:dio/dio.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';

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
}
