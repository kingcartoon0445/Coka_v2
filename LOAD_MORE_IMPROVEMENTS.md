# Cải tiến Load More - Mượt mà hơn

## Vấn đề ban đầu
- Khi load more, toàn bộ màn hình bị reload thay vì chỉ append dữ liệu mới
- Scroll position bị mất khi load more
- Có thể gọi load more nhiều lần liên tiếp
- Loading indicator không mượt mà

## Những cải tiến đã thực hiện

### 1. Không thay đổi status khi load more
```dart
// Trước đây - gây reload toàn bộ UI
emit(state.copyWith(
  status: CustomerServiceStatus.success, // ❌ Gây reload
  customerServices: updatedCustomers,
  customersMetadata: customerServiceResponse.metadata,
  hasMoreCustomers: hasMore,
));

// Bây giờ - chỉ cập nhật dữ liệu
emit(state.copyWith(
  customerServices: updatedCustomers,
  customersMetadata: customerServiceResponse.metadata,
  hasMoreCustomers: hasMore,
)); // ✅ Không thay đổi status
```

### 2. Cải thiện Loading Indicator
```dart
// Trước đây - chỉ có CircularProgressIndicator
const CircularProgressIndicator()

// Bây giờ - có text và animation mượt mà hơn
Column(
  children: [
    const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    const SizedBox(height: 8),
    Text(
      'Đang tải thêm...',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    ),
  ],
)
```

### 3. Giữ nguyên Scroll Position
```dart
void _loadMore() {
  // Lưu vị trí scroll hiện tại
  final currentScrollPosition = _scrollController.position.pixels;
  
  // Gọi API load more
  context.read<CustomerServiceBloc>().add(LoadMoreCustomers(...));
  
  // Khôi phục vị trí scroll sau khi state được cập nhật
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && _scrollController.hasClients) {
      _scrollController.animateTo(
        currentScrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  });
}
```

### 4. Tránh Duplicate Requests
```dart
class _CustomersListState extends State<CustomersList> {
  bool _isLoadingMore = false; // Thêm flag để track
  
  void _loadMore() {
    if (state.hasMoreCustomers && 
        state.status != CustomerServiceStatus.loadingMore &&
        !_isLoadingMore) { // ✅ Kiểm tra flag
      _isLoadingMore = true;
      
      // Gọi API...
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Khôi phục scroll position...
        _isLoadingMore = false; // ✅ Reset flag
      });
    }
  }
}
```

### 5. Cải thiện UI States
```dart
BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
  builder: (context, state) {
    // Show shimmer loading only for initial load when no data
    if (state.status == CustomerServiceStatus.loading && 
        state.customerServices.isEmpty) {
      return Column(children: List.generate(5, (index) => _buildShimmerItem()));
    }

    // Show error only when no data
    if (state.status == CustomerServiceStatus.error && 
        state.customerServices.isEmpty) {
      return Center(child: ErrorWidget(...));
    }

    // Show empty state
    if (state.customerServices.isEmpty) {
      return Center(child: Text('Không có khách hàng nào'));
    }

    // Show list with load more
    return ListView.builder(
      itemCount: state.customerServices.length + (state.hasMoreCustomers ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.customerServices.length) {
          // Show loading indicator at the bottom for load more
          if (state.status == CustomerServiceStatus.loadingMore) {
            return LoadMoreIndicator();
          }
          return const SizedBox.shrink();
        }
        return CustomerListItem(...);
      },
    );
  },
)
```

## Kết quả

### ✅ Trước khi cải tiến
- Màn hình bị reload khi load more
- Scroll position bị mất
- Có thể gọi load more nhiều lần
- Loading indicator đơn giản

### ✅ Sau khi cải tiến
- Chỉ append dữ liệu mới, không reload toàn bộ
- Giữ nguyên scroll position với animation mượt mà
- Tránh duplicate requests
- Loading indicator đẹp và thông tin hơn
- UX mượt mà và chuyên nghiệp

## Cách hoạt động

1. **Scroll Detection**: Khi cuộn gần cuối (cách 200px), kích hoạt load more
2. **Save Position**: Lưu vị trí scroll hiện tại
3. **API Call**: Gọi API với offset mới
4. **Update State**: Chỉ cập nhật dữ liệu, không thay đổi status
5. **Restore Position**: Khôi phục vị trí scroll với animation
6. **Show Loading**: Hiển thị loading indicator ở cuối danh sách

## Lợi ích

- **Performance**: Không rebuild toàn bộ UI
- **UX**: Trải nghiệm mượt mà, không bị giật
- **Reliability**: Tránh duplicate requests
- **Visual**: Loading indicator đẹp và thông tin
- **Maintainability**: Code sạch và dễ hiểu

## Testing

Để test tính năng load more mượt mà:
1. Cuộn xuống cuối danh sách
2. Kiểm tra loading indicator xuất hiện ở cuối
3. Xác nhận scroll position được giữ nguyên
4. Kiểm tra dữ liệu mới được append
5. Test cuộn nhanh để đảm bảo không có duplicate requests 