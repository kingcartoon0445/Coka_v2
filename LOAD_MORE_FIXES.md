# Sửa lỗi Load More

## Vấn đề đã phát hiện

1. **Flag `_isLoadingMore` không được reset** - Khiến load more chỉ hoạt động một lần
2. **Status không được reset về success** - Có thể gây vấn đề với UI states
3. **Initial data không được load** - `_loadInitialData()` bị comment out
4. **Error handling không phù hợp** - Set error status khi load more thất bại

## Những sửa đổi đã thực hiện

### 1. Reset flag `_isLoadingMore`
```dart
// Trước đây - flag không được reset
WidgetsBinding.instance.addPostFrameCallback((_) {
  // _isLoadingMore = false; // ❌ Bị comment out
});

// Bây giờ - reset flag sau khi gọi API
WidgetsBinding.instance.addPostFrameCallback((_) {
  print('Resetting isLoadingMore flag');
  _isLoadingMore = false; // ✅ Reset flag
});
```

### 2. Reset status về success khi load more thành công
```dart
// Trước đây - không reset status
emit(state.copyWith(
  customerServices: updatedCustomers,
  customersMetadata: customerServiceResponse.metadata,
  hasMoreCustomers: hasMore,
));

// Bây giờ - reset status về success
emit(state.copyWith(
  status: CustomerServiceStatus.success, // ✅ Reset status
  customerServices: updatedCustomers,
  customersMetadata: customerServiceResponse.metadata,
  hasMoreCustomers: hasMore,
));
```

### 3. Enable initial data loading
```dart
// Trước đây - bị comment out
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   _loadInitialData();
// });

// Bây giờ - enable lại
WidgetsBinding.instance.addPostFrameCallback((_) {
  _loadInitialData(); // ✅ Load initial data
});
```

### 4. Cải thiện error handling cho load more
```dart
// Trước đây - luôn set error status
} else {
  emit(state.copyWith(
    status: CustomerServiceStatus.error,
    error: response.data['message'] as String? ?? 'Unknown error',
  ));
}

// Bây giờ - chỉ set error khi cần thiết
} else {
  // Chỉ set error nếu đây là lần load đầu tiên
  if (state.customerServices.isEmpty) {
    emit(state.copyWith(
      status: CustomerServiceStatus.error,
      error: response.data['message'] as String? ?? 'Unknown error',
    ));
  } else {
    // Nếu đã có dữ liệu, chỉ log error mà không thay đổi status
    print('Load more error: ${response.data['message']}');
  }
}
```

### 5. Thêm debug logs
```dart
void _loadMore() {
  final state = context.read<CustomerServiceBloc>().state;
  print('LoadMore called - hasMore: ${state.hasMoreCustomers}, status: ${state.status}, isLoadingMore: $_isLoadingMore, offset: $_currentOffset');
  
  if (state.hasMoreCustomers &&
      state.status != CustomerServiceStatus.loadingMore &&
      !_isLoadingMore) {
    print('Starting load more with offset: $_currentOffset');
    // ... rest of the code
  }
}
```

## Cách hoạt động sau khi sửa

1. **Initial Load**: `_loadInitialData()` được gọi khi widget khởi tạo
2. **Scroll Detection**: Khi cuộn gần cuối, `_loadMore()` được gọi
3. **Flag Check**: Kiểm tra `_isLoadingMore` để tránh duplicate requests
4. **API Call**: Gọi API với offset mới
5. **State Update**: Cập nhật dữ liệu và reset status về success
6. **Flag Reset**: Reset `_isLoadingMore` flag để cho phép load more tiếp theo

## Testing

Để test load more sau khi sửa:

1. **Initial Load**: Kiểm tra dữ liệu ban đầu được load
2. **Scroll to Bottom**: Cuộn xuống cuối danh sách
3. **Load More**: Kiểm tra loading indicator xuất hiện
4. **Data Append**: Xác nhận dữ liệu mới được thêm vào
5. **Multiple Loads**: Test load more nhiều lần liên tiếp
6. **Error Handling**: Test khi có lỗi network

## Debug Logs

Các log sẽ hiển thị trong console:
```
LoadMore called - hasMore: true, status: success, isLoadingMore: false, offset: 20
Starting load more with offset: 20
Resetting isLoadingMore flag
```

## Lưu ý

- **Flag Management**: `_isLoadingMore` được set true khi bắt đầu load more và reset false sau khi hoàn thành
- **Status Management**: Status được reset về success sau khi load more thành công
- **Error Handling**: Chỉ set error status khi thực sự cần thiết (initial load)
- **Initial Data**: Đảm bảo dữ liệu ban đầu được load khi widget khởi tạo 