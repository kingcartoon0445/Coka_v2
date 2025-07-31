# Tích hợp Load More vào CustomersList Widget

## Tổng quan
Đã tích hợp thành công tính năng load more vào widget `CustomersList`, cho phép tải thêm dữ liệu customers khi người dùng cuộn xuống cuối danh sách.

## Những thay đổi đã thực hiện

### 1. Thêm Event LoadMoreCustomers
```dart
class LoadMoreCustomers extends CustomerServiceEvent {
  final String organizationId;
  final LeadPagingRequest pagingRequest;

  const LoadMoreCustomers({
    required this.organizationId,
    required this.pagingRequest,
  });
}
```

### 2. Cập nhật CustomerServiceState
```dart
class CustomerServiceState extends Equatable {
  // ... existing fields
  final Metadata? customersMetadata;
  final bool hasMoreCustomers;
}
```

### 3. Cập nhật CustomerServiceBloc
- Thêm handler cho `LoadMoreCustomers` event
- Cập nhật `_onLoadCustomerService` để tính toán pagination metadata
- Thêm method `_onLoadMoreCustomers` để xử lý load more

### 4. Cập nhật CustomersList Widget
```dart
class _CustomersListState extends State<CustomersList> {
  final ScrollController _scrollController = ScrollController();
  final int _limit = 20;
  int _currentOffset = 0;
  bool _isFirstLoad = true;
```

### 5. Thêm Scroll Detection và Load More Logic
```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _loadMore();
  }
}

void _loadMore() {
  final state = context.read<CustomerServiceBloc>().state;
  if (state.hasMoreCustomers && 
      state.status != CustomerServiceStatus.loadingMore) {
    _currentOffset += _limit;
    
    final pagingRequest = LeadPagingRequest(
      limit: _limit,
      offset: _currentOffset,
      searchText: widget.searchQuery,
    );
    
    context.read<CustomerServiceBloc>().add(
      LoadMoreCustomers(
        organizationId: widget.organizationId,
        pagingRequest: pagingRequest,
      ),
    );
  }
}
```

### 6. Thay đổi từ PagingController sang BlocBuilder
```dart
// Trước đây
PagingListener<int, CustomerServiceModel>(
  controller: _pagingController,
  // ...
)

// Bây giờ
BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
  builder: (context, state) {
    // Handle different states and render ListView
  },
)
```

## Cách hoạt động

1. **Initial Load**: Khi widget được khởi tạo, gọi `_loadInitialData()` với offset = 0
2. **Scroll Detection**: Theo dõi vị trí cuộn và kích hoạt load more khi cuộn gần cuối (cách 200px)
3. **Pagination Logic**: Sử dụng `_currentOffset` để theo dõi vị trí hiện tại
4. **State Management**: Kiểm tra `state.hasMoreCustomers` và `state.status` để tránh duplicate requests
5. **Loading States**: Hiển thị shimmer loading cho initial load và loading indicator cho load more

## Tính năng mới

- **Automatic Load More**: Tự động tải khi cuộn gần cuối danh sách
- **Loading States**: Hiển thị rõ ràng cho initial load và load more
- **Error Handling**: Xử lý lỗi với retry functionality
- **Pull to Refresh**: Refresh toàn bộ danh sách khi kéo xuống
- **Search Integration**: Hỗ trợ search với pagination
- **Memory Efficient**: Chỉ tải dữ liệu khi cần thiết

## API Integration

Sử dụng `LeadPagingRequest` model để gửi pagination parameters:
```dart
LeadPagingRequest(
  limit: _limit,
  offset: _currentOffset,
  searchText: widget.searchQuery,
)
```

## Testing

Để test tính năng load more:
1. Đảm bảo có nhiều customers (hơn 20 items)
2. Cuộn xuống cuối danh sách
3. Kiểm tra loading indicator xuất hiện
4. Xác nhận customers mới được thêm vào danh sách
5. Test pull to refresh functionality
6. Test error scenarios và retry

## Lợi ích

- **Performance**: Giảm tải cho server và client
- **UX**: Trải nghiệm mượt mà, không bị gián đoạn
- **Scalability**: Hỗ trợ danh sách lớn mà không ảnh hưởng performance
- **Integration**: Tích hợp hoàn toàn với existing bloc pattern
- **Maintainability**: Code sạch và dễ maintain

## Lưu ý

- Page size mặc định: 20 items
- Scroll threshold: 200px từ cuối danh sách
- Chỉ load more khi `hasMoreCustomers = true`
- Tránh duplicate requests bằng cách kiểm tra `loadingMore` status
- Tự động reset offset khi refresh hoặc thay đổi search query 