# Load More Facebook Chats Implementation

## Tổng quan
Tính năng load more cho Facebook chats đã được implement với các thành phần sau:

## 1. State Management

### CustomerServiceState
- Thêm `facebookChatsMetadata`: Metadata cho pagination
- Thêm `hasMoreFacebookChats`: Boolean để kiểm tra còn dữ liệu không

### Events
- `LoadFacebookChat`: Load dữ liệu đầu tiên
- `LoadMoreFacebookChats`: Load thêm dữ liệu với offset và limit

## 2. Repository Layer

### OrganizationRepository
- `getFacebookChat()`: Load dữ liệu đầu tiên (offset: 0, limit: 20)
- `getFacebookChatPaging()`: Load dữ liệu với pagination

## 3. Bloc Logic

### _onLoadFacebookChat
- Load dữ liệu đầu tiên
- Tính toán `hasMoreFacebookChats` dựa trên metadata
- Lưu metadata để sử dụng cho load more

### _onLoadMoreFacebookChats
- Load thêm dữ liệu với offset và limit
- Append dữ liệu mới vào list hiện tại
- Cập nhật metadata và hasMore flag

## 4. UI Implementation

### Scroll Listener
- Trigger load more khi scroll đến 80% cuối list
- Kiểm tra `hasMoreFacebookChats` và `status != loadingMore`

### ListView
- `itemCount`: Thêm 1 item cho loading indicator nếu có more data
- Loading indicator hiển thị ở cuối list

### Loading States
- `loading`: Khi load dữ liệu đầu tiên
- `loadingMore`: Khi load thêm dữ liệu
- `success`: Khi load thành công

## 5. Debug Logging

### Bloc Logging
- Log khi bắt đầu load
- Log response data
- Log số lượng items loaded
- Log hasMore status

### UI Logging
- Log state status
- Log số lượng Facebook chats
- Log hasMore status
- Log metadata

## 6. Cách sử dụng

1. Widget tự động load dữ liệu khi khởi tạo
2. User scroll xuống cuối để trigger load more
3. Loading indicator hiển thị khi đang load
4. Dữ liệu mới được append vào list hiện tại

## 7. API Endpoint

```
GET /api/v1/omni/conversation/getlistpaging
Headers: { 'organizationId': organizationId }
Query: {
  'provider': 'FACEBOOK',
  'offset': offset,
  'limit': limit,
  'sort': '[{ Column: "CreatedDate", Dir: "DESC" }]'
}
```

## 8. Response Format

```json
{
  "code": 0,
  "content": [...],
  "metadata": {
    "offset": 0,
    "count": 20,
    "total": 100
  }
}
```

## 9. Pagination Logic

```dart
final hasMore = metadata != null &&
    (metadata.offset + metadata.count) < metadata.total;
```

## 10. Testing

Để test tính năng:
1. Mở Facebook chat tab
2. Scroll xuống cuối list
3. Kiểm tra console logs
4. Verify dữ liệu được append đúng
5. Verify loading indicator hiển thị
6. Verify hasMore flag hoạt động đúng 