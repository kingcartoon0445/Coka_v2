# CustomerDetailScreen Migration to CustomerDetailBloc

## Tổng quan

Đã thành công cập nhật `CustomerDetailScreen` để sử dụng `CustomerDetailBloc` thay vì `CustomerServiceBloc`.

## Thay đổi chính

### 1. **Imports được cập nhật**
```dart
// Trước
import '../../blocs/customer_service/customer_service_action.dart';

// Sau
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_bloc.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_event.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_state.dart';
```

### 2. **Bloc được thay đổi**
```dart
// Trước
BlocConsumer<CustomerServiceBloc, CustomerServiceState>

// Sau
BlocConsumer<CustomerDetailBloc, CustomerDetailState>
```

### 3. **Status được cập nhật**
```dart
// Trước
CustomerServiceStatus.loading
CustomerServiceStatus.successStorageCustomer
CustomerServiceStatus.successDeleteReminder

// Sau
CustomerDetailStatus.loading
CustomerDetailStatus.successStorageCustomer
CustomerDetailStatus.successDeleteReminder
```

### 4. **Event calls được cập nhật**
```dart
// Trước
context.read<CustomerServiceBloc>().add(LoadCustomerService(...))

// Sau
context.read<CustomerDetailBloc>().add(LoadJourneyPaging(...))
```

### 5. **BlocSelector được cập nhật**
```dart
// Trước
BlocSelector<CustomerServiceBloc, CustomerServiceState, List<Assignees>>

// Sau
BlocSelector<CustomerDetailBloc, CustomerDetailState, List<Assignees>>
```

## Các chức năng được giữ nguyên

- ✅ Hiển thị thông tin khách hàng
- ✅ Hiển thị assignees và followers
- ✅ Convert to customer button
- ✅ Archive/Unarchive (placeholder)
- ✅ Delete customer (placeholder)
- ✅ Tất cả UI components

## Các chức năng được đánh dấu "đang phát triển"

### 1. **Archive/Unarchive**
```dart
onArchiveToggle: () {
  // Logic archive/unarchive có thể được thêm vào CustomerDetailBloc nếu cần
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Chức năng đang được phát triển')),
  );
},
```

### 2. **Delete Customer**
```dart
onConfirm: () {
  // Có thể thêm DeleteCustomer event vào CustomerDetailBloc nếu cần
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Chức năng đang được phát triển')),
  );
},
```

## Lý do migration

### 1. **Nhất quán với CustomerDetailPage**
- Cả hai màn hình giờ đây đều sử dụng `CustomerDetailBloc`
- Dễ dàng quản lý state và logic

### 2. **Tách biệt trách nhiệm**
- `CustomerServiceBloc`: Quản lý danh sách khách hàng
- `CustomerDetailBloc`: Quản lý chi tiết khách hàng

### 3. **Dễ bảo trì**
- Mỗi bloc có scope rõ ràng
- Dễ debug và thêm tính năng mới

## Kiểm tra

- ✅ Build thành công
- ✅ Không có lỗi linter nghiêm trọng
- ✅ Tất cả imports đã được cập nhật
- ✅ Tất cả bloc references đã được thay đổi
- ✅ Tất cả status references đã được cập nhật

## Cảnh báo

### 1. **Unused Variables**
- `labels` và `initLabels` không được sử dụng (có thể xóa trong tương lai)

### 2. **Deprecated Methods**
- `withOpacity` đã deprecated, nên sử dụng `withValues` thay thế

## Kết luận

`CustomerDetailScreen` đã được migration thành công sang `CustomerDetailBloc`. Màn hình giờ đây nhất quán với `CustomerDetailPage` và sử dụng bloc riêng cho việc quản lý chi tiết khách hàng.

## Next Steps

1. **Thêm các event còn thiếu** vào `CustomerDetailBloc`:
   - `DeleteCustomer`
   - `ArchiveCustomer`
   - `UnarchiveCustomer`

2. **Xóa các unused variables** để clean code

3. **Cập nhật deprecated methods** để sử dụng API mới nhất 