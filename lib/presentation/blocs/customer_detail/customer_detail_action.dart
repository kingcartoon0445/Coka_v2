import 'package:source_base/presentation/blocs/customer_detail/customer_detail_bloc.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_event.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_state.dart';

class CustomerDetailAction {
  final CustomerDetailBloc _bloc;

  CustomerDetailAction(this._bloc);

  void loadCustomerDetail(String organizationId, String customerId) {
    _bloc.add(LoadCustomerDetail(
      organizationId: organizationId,
      customerId: customerId,
    ));
  }

  void loadJourneyPaging(String organizationId, {String? type}) {
    _bloc.add(LoadCustomerDetailValue(
      organizationId: organizationId,
      type: type,
    ));
  }

  void loadMoreServiceDetails(String organizationId, int limit, int offset,
      {String? type}) {
    _bloc.add(LoadMoreServiceDetails(
      organizationId: organizationId,
      limit: limit,
      offset: offset,
      type: type,
    ));
  }

  void postCustomerNote(String customerId, String customerName, String note,
      String organizationId) {
    _bloc.add(PostCustomerNote(
      customerId: customerId,
      customerName: customerName,
      note: note,
      organizationId: organizationId,
    ));
  }

  void updateNoteMark(String scheduleId, bool isDone, String notes) {
    _bloc.add(UpdateNoteMark(
      ScheduleId: scheduleId,
      isDone: isDone,
      Notes: notes,
    ));
  }

  void createReminder(String organizationId, dynamic body) {
    _bloc.add(CreateReminder(
      organizationId: organizationId,
      body: body,
    ));
  }

  void updateReminder(String organizationId, dynamic body) {
    _bloc.add(UpdateReminder(
      organizationId: organizationId,
      body: body,
    ));
  }

  void deleteReminder(String organizationId, String reminderId) {
    _bloc.add(DeleteReminder(
      organizationId: organizationId,
      reminderId: reminderId,
    ));
  }

  void loadPaginges(String organizationId) {
    _bloc.add(LoadPaginges(organizationId: organizationId));
  }

  void showError(String error, CustomerDetailStatus status) {
    _bloc.add(ShowError(error: error, status: status));
  }

  void dispose() {
    _bloc.add(const DisposeCustomerDetail());
  }
}
