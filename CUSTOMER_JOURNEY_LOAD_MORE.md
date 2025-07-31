# Tích hợp Load More vào CustomerJourney Widget

## Tổng quan
Đã tích hợp thành công tính năng load more vào widget `CustomerJourney` hiện tại, cho phép tải thêm dữ liệu `serviceDetails` khi người dùng cuộn xuống cuối danh sách.

## Những thay đổi đã thực hiện

### 1. Thêm ScrollController và Pagination Logic
```dart
class _CustomerJourneyState extends State<CustomerJourney>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _currentOffset = 0;
  static const int _pageSize = 20;
```

### 2. Thêm Scroll Listener
```dart
@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  // ... existing code
}

void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _loadMore();
  }
}
```

### 3. Thêm Load More Method
```dart
void _loadMore() {
  final state = context.read<CustomerServiceBloc>().state;
  if (state.hasMoreServiceDetails && 
      state.status != CustomerServiceStatus.loadingMore) {
    _currentOffset += _pageSize;
    context.read<CustomerServiceBloc>().add(
      LoadMoreServiceDetails(
        organizationId: context.read<OrganizationBloc>().state.organizationId ?? '',
        limit: _pageSize,
        offset: _currentOffset,
      ),
    );
  }
}
```

### 4. Thay đổi từ SingleChildScrollView sang ListView
```dart
// Trước đây
return SingleChildScrollView(
  child: Column(
    children: [...]
  ),
);

// Bây giờ
return ListView(
  controller: _scrollController,
  children: [...]
);
```

### 5. Thêm Loading Indicator cho Load More
```dart
// Loading indicator cho load more
if (state.hasMoreServiceDetails)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: state.status == CustomerServiceStatus.loadingMore
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
    ),
  ),
```

### 6. Thêm Import cần thiết
```dart
import '../../../../blocs/customer_service/customer_service_event.dart';
```

## Cách hoạt động

1. **Scroll Detection**: Widget theo dõi vị trí cuộn và tự động kích hoạt load more khi người dùng cuộn đến gần cuối danh sách (cách cuối 200px)

2. **Pagination Logic**: Sử dụng `_currentOffset` để theo dõi vị trí hiện tại và `_pageSize` để xác định số lượng item mỗi lần tải

3. **State Management**: Kiểm tra `state.hasMoreServiceDetails` và `state.status` để tránh gọi API không cần thiết

4. **Loading States**: Hiển thị `CircularProgressIndicator` khi đang tải thêm dữ liệu

5. **Memory Management**: Tự động dispose `ScrollController` khi widget bị hủy

## Lợi ích

- **Performance**: Chỉ tải dữ liệu khi cần thiết, giảm tải cho server
- **UX**: Trải nghiệm mượt mà, không bị gián đoạn
- **Memory Efficient**: Không load tất cả dữ liệu cùng lúc
- **Seamless Integration**: Tích hợp hoàn toàn vào UI hiện tại

## Testing

Để test tính năng load more:
1. Đảm bảo có nhiều dữ liệu serviceDetails (hơn 20 items)
2. Cuộn xuống cuối danh sách
3. Kiểm tra xem loading indicator có xuất hiện không
4. Xác nhận dữ liệu mới được thêm vào danh sách
5. Kiểm tra scroll position được giữ nguyên

## Lưu ý

- Page size được set mặc định là 20 items
- Scroll threshold là 200px từ cuối danh sách
- Chỉ load more khi có dữ liệu còn lại (`hasMoreServiceDetails = true`)
- Tránh duplicate requests bằng cách kiểm tra `loadingMore` status 