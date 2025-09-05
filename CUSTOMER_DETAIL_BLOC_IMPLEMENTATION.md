# CustomerDetailBloc Implementation

## Tổng quan

Đã tách thành công `CustomerDetailPage` để sử dụng bloc riêng `CustomerDetailBloc` thay vì `CustomerServiceBloc`.

## Cấu trúc mới

### 1. CustomerDetailState
- **File**: `lib/presentation/blocs/customer_detail/customer_detail_state.dart`
- **Mô tả**: State riêng cho detail page với các trường cần thiết
- **Trường chính**:
  - `customerService`: Thông tin khách hàng hiện tại
  - `serviceDetails`: Danh sách chi tiết dịch vụ
  - `scheduleDetails`: Danh sách lịch trình
  - `customerDetail`: Chi tiết khách hàng
  - `status`: Trạng thái hiện tại

### 2. CustomerDetailEvent
- **File**: `lib/presentation/blocs/customer_detail/customer_detail_event.dart`
- **Mô tả**: Các event cần thiết cho detail page
- **Event chính**:
  - `LoadCustomerDetail`: Load thông tin chi tiết khách hàng
  - `LoadJourneyPaging`: Load hành trình khách hàng
  - `LoadMoreServiceDetails`: Load thêm chi tiết dịch vụ
  - `PostCustomerNote`: Đăng ghi chú
  - `CreateReminder`: Tạo reminder
  - `UpdateReminder`: Cập nhật reminder
  - `DeleteReminder`: Xóa reminder

### 3. CustomerDetailBloc
- **File**: `lib/presentation/blocs/customer_detail/customer_detail_bloc.dart`
- **Mô tả**: Logic xử lý các event cho detail page
- **Repository sử dụng**:
  - `OrganizationRepository`
  - `CalendarRepository`
  - `DealActivityRepository`

### 4. CustomerDetailAction
- **File**: `lib/presentation/blocs/customer_detail/customer_detail_action.dart`
- **Mô tả**: Wrapper class để dễ dàng gọi các action từ UI

## Cách sử dụng

### 1. Trong UI
```dart
// Sử dụng BlocBuilder
BlocBuilder<CustomerDetailBloc, CustomerDetailState>(
  bloc: context.read<CustomerDetailBloc>(),
  builder: (context, state) {
    // UI logic
  },
)

// Gọi event
context.read<CustomerDetailBloc>().add(
  LoadCustomerDetail(
    organizationId: 'org_id',
    customerId: 'customer_id',
  ),
)
```

### 2. Đăng ký trong Service Locator
```dart
getIt.registerFactory<CustomerDetailBloc>(() => CustomerDetailBloc(
  organizationRepository: getIt<OrganizationRepository>(),
  calendarRepository: getIt<CalendarRepository>(),
  dealActivityRepository: getIt<DealActivityRepository>(),
));
```

### 3. Cung cấp trong App
```dart
BlocProvider<CustomerDetailBloc>(
  create: (_) => getIt<CustomerDetailBloc>(),
),
```

## Lợi ích

### 1. Tách biệt trách nhiệm
- `CustomerServiceBloc`: Quản lý danh sách khách hàng
- `CustomerDetailBloc`: Quản lý chi tiết khách hàng

### 2. Dễ bảo trì
- Mỗi bloc có scope nhỏ hơn
- Dễ debug và maintain
- Code rõ ràng, dễ hiểu

### 3. Performance
- Không cần load toàn bộ state khi chỉ cần detail
- State nhỏ gọn, tối ưu cho detail page

### 4. Tái sử dụng
- Có thể sử dụng `CustomerDetailBloc` ở các màn hình khác cần detail
- Dễ dàng mở rộng và thêm tính năng mới

## Migration

### Từ CustomerServiceBloc sang CustomerDetailBloc

**Trước:**
```dart
BlocBuilder<CustomerServiceBloc, CustomerServiceState>
context.read<CustomerServiceBloc>().add(LoadCustomerDetail(...))
```

**Sau:**
```dart
BlocBuilder<CustomerDetailBloc, CustomerDetailState>
context.read<CustomerDetailBloc>().add(LoadCustomerDetail(...))
```

### Thay đổi Status
```dart
// Trước
CustomerServiceStatus.loadingUserInfo
CustomerServiceStatus.loading

// Sau
CustomerDetailStatus.loadingUserInfo
CustomerDetailStatus.loading
```

## Kiểm tra

- ✅ Build thành công
- ✅ Không có lỗi linter nghiêm trọng
- ✅ Tất cả import đã được cập nhật
- ✅ Service locator đã đăng ký
- ✅ App đã cung cấp bloc

## Kết luận

Việc tách `CustomerDetailBloc` đã hoàn thành thành công. Detail page giờ đây có bloc riêng, độc lập với `CustomerServiceBloc`, giúp code dễ bảo trì và mở rộng hơn. 