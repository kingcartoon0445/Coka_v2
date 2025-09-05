# Hệ Thống Routing - Coka v2

## Tổng Quan

Ứng dụng sử dụng **GoRouter** để quản lý navigation với cấu trúc routing rõ ràng và có tổ chức.

## Cấu Trúc Routing

### 1. Auth Routes (Xác thực)
- `/login` - Màn hình đăng nhập ✅
- `/register` - Màn hình đăng ký (placeholder)
- `/complete-profile` - Hoàn thiện hồ sơ ✅
- `/verify-otp` - Xác thực OTP ✅

### 2. Main Routes (Chính)
- `/splash` - Màn hình khởi động
- `/home` - Màn hình chính ✅

### 3. Organization Routes (Tổ chức)
- `/organization` - Danh sách tổ chức (placeholder)
- `/organization/:organizationId` - Chi tiết tổ chức với nested routes ✅

#### Nested Routes trong Organization:
- `/organization/:organizationId/customers` - Danh sách khách hàng (placeholder)
- `/organization/:organizationId/customers/add` - Thêm khách hàng (placeholder)
- `/organization/:organizationId/customers/edit` - Sửa khách hàng (placeholder)
- `/organization/:organizationId/customers/:customerId` - Chi tiết khách hàng ✅
- `/organization/:organizationId/deal-activity` - Hoạt động giao dịch ✅
- `/organization/:organizationId/final-deal` - Giao dịch cuối cùng ✅
- `/organization/:organizationId/final-deal/:dealId` - Chi tiết giao dịch ✅
- `/organization/:organizationId/chat` - Chat ✅
- `/organization/:organizationId/chat/:chatId` - Chi tiết chat ✅

### 4. Standalone Routes (Độc lập)
- `/customer-service` - Dịch vụ khách hàng ✅
- `/customers` - Danh sách khách hàng (placeholder)
- `/customers/add` - Thêm khách hàng (placeholder)
- `/customers/edit` - Sửa khách hàng (placeholder)
- `/customer` - Màn hình khách hàng ✅
- `/customer/:customerId` - Chi tiết khách hàng ✅
- `/deal-activity` - Hoạt động giao dịch ✅
- `/final-deal` - Giao dịch cuối cùng ✅
- `/chat` - Chat ✅

### 5. Theme & Settings Routes
- `/theme` - Cài đặt giao diện (placeholder)
- `/theme/reminder` - Giao diện nhắc nhở (placeholder)
- `/settings` - Cài đặt chung (placeholder)
- `/profile` - Hồ sơ người dùng (placeholder)
- `/notifications` - Thông báo (placeholder)
- `/about` - Thông tin ứng dụng (placeholder)

## Danh Sách Màn Hình Đã Hoàn Thành

### ✅ Đã Có Implementation:
- `LoginPage` - Màn hình đăng nhập
- `CompleteProfilePage` - Hoàn thiện hồ sơ
- `VerifyOtpScreen` - Xác thực OTP
- `HomeScreen` - Màn hình chính
- `OrganizationPage` - Trang tổ chức
- `CustomerDetailPage` - Chi tiết khách hàng
- `DealActivityScreen` - Hoạt động giao dịch
- `FinalDealScreen` - Giao dịch cuối cùng
- `DetailDealPage` - Chi tiết giao dịch
- `ChatDetailPage` - Chat
- `CustomerDetailScreen` - Màn hình khách hàng

### 🔧 Cần Implementation:
- `RegisterScreen` - Màn hình đăng ký
- `CustomersPage` - Danh sách khách hàng
- `AddCustomerPage` - Thêm khách hàng
- `EditCustomerPage` - Sửa khách hàng
- Các màn hình Settings & Theme

## Cách Sử Dụng

### 1. Navigation Helper Methods

```dart
// Auth navigation
AppNavigation.goToLogin(context);
AppNavigation.goToRegister(context);
AppNavigation.goToCompleteProfile(context);
AppNavigation.goToVerifyOtp(context, 'email', 'otpId');

// Main navigation
AppNavigation.goToHome(context);
AppNavigation.goToSplash(context);

// Organization navigation
AppNavigation.goToOrganization(context);
AppNavigation.goToOrganizationDetail(context, 'org123');

// Customer service navigation
AppNavigation.goToCustomerService(context);
AppNavigation.goToCustomers(context);
AppNavigation.goToAddCustomer(context);
AppNavigation.goToEditCustomer(context);
AppNavigation.goToCustomerDetail(context, 'customer456');

// Customer navigation
AppNavigation.goToCustomer(context);
AppNavigation.goToCustomerDetailScreen(context, 'customer456');

// Deal activity navigation
AppNavigation.goToDealActivity(context);

// Final deal navigation
AppNavigation.goToFinalDeal(context);
AppNavigation.goToFinalDealDetail(context, 'deal123');

// Chat navigation
AppNavigation.goToChat(context);
AppNavigation.goToChatDetail(context, 'chat456');

// Theme navigation
AppNavigation.goToTheme(context);
AppNavigation.goToReminderTheme(context);

// Settings navigation
AppNavigation.goToSettings(context);
AppNavigation.goToProfile(context);
AppNavigation.goToNotifications(context);
AppNavigation.goToAbout(context);

// Back navigation
AppNavigation.goBack(context);
```

### 2. Truy Cập Route Parameters

```dart
// Trong màn hình
final organizationId = GoRouterState.of(context).pathParameters['organizationId'];
final customerId = GoRouterState.of(context).pathParameters['customerId'];
final dealId = GoRouterState.of(context).pathParameters['dealId'];
final chatId = GoRouterState.of(context).pathParameters['chatId'];
```

### 3. Query Parameters

```dart
// Chuyển đến verify OTP với query params
AppNavigation.goToVerifyOtp(context, 'user@example.com', 'otp123');

// Trong màn hình verify OTP
final queryParams = GoRouterState.of(context).uri.queryParameters;
final email = queryParams['email'];
final otpId = queryParams['otpId'];
```

## Shell Route

Ứng dụng sử dụng `ShellRoute` để tạo layout chung cho các màn hình trong tổ chức:

```dart
ShellRoute(
  builder: (context, state, child) {
    if (state.matchedLocation.startsWith('/organization/')) {
      final organizationId = state.pathParameters['organizationId'];
      if (organizationId != null) {
        return OrganizationPage(
          organizationId: organizationId,
          child: child,
        );
      }
    }
    return child;
  },
  routes: [
    // Nested routes...
  ],
)
```

## Error Handling

Router có xử lý lỗi tích hợp:

```dart
errorBuilder: (context, state) => Scaffold(
  appBar: AppBar(title: const Text('Page Not Found')),
  body: Center(
    child: Column(
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        Text('Page not found: ${state.matchedLocation}'),
        ElevatedButton(
          onPressed: () => context.go(AppPaths.home),
          child: const Text('Go Home'),
        ),
      ],
    ),
  ),
),
```

## Authentication & Redirects

Router hỗ trợ redirect logic để kiểm tra xác thực:

```dart
redirect: (context, state) {
  // TODO: Thêm logic kiểm tra xác thực
  // final isLoggedIn = checkAuthStatus();
  // if (!isLoggedIn && state.matchedLocation != AppPaths.login) {
  //   return AppPaths.login;
  // }
  return null;
},
```

## Placeholder Screens

Các màn hình chưa được phát triển sẽ hiển thị placeholder với thông báo "under development":

```dart
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  
  const _PlaceholderScreen({required this.title, required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            Text(message),
            Text('This screen is under development'),
          ],
        ),
      ),
    );
  }
}
```

## Cập Nhật Routing

Để thêm route mới:

1. Thêm path constant vào `AppPaths`
2. Thêm navigation method vào `AppNavigation`
3. Thêm `GoRoute` vào router configuration
4. Cập nhật documentation này

## Lưu Ý

- Tất cả routes đều có tên duy nhất
- Sử dụng `context.go()` thay vì `Navigator.push()`
- ShellRoute tạo layout chung cho organization context
- Placeholder screens cho các màn hình chưa hoàn thiện
- Error handling tích hợp sẵn
- Hỗ trợ query parameters và path parameters
- Các màn hình cần parameters được đánh dấu (placeholder) để tránh lỗi
- Cấu trúc routing đơn giản và dễ maintain 