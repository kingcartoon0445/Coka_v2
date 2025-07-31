# Tạo Event CreateReminder và Gắn vào _saveReminder

## Tổng quan

Đã implement event `CreateReminder` trong `CustomerServiceBloc` và gắn vào method `_saveReminder` trong `AddReminderDialog`. Khi tạo reminder mới, dữ liệu ảo sẽ được thêm vào `serviceDetails` để hiển thị ngay lập tức trong view.

## Các thay đổi đã thực hiện

### 1. Thêm Event Handler trong CustomerServiceBloc

**File**: `lib/presentation/blocs/customer_service/customer_service_bloc.dart`

```dart
// Thêm event handler
on<CreateReminder>(_onCreateReminder);

// Thêm method xử lý
Future<void> _onCreateReminder(
  CreateReminder event,
  Emitter<CustomerServiceState> emit,
) async {
  try {
    emit(state.copyWith(status: CustomerServiceStatus.loading));

    // TODO: Gọi API thực tế khi có
    // final response = await calendarRepository.createReminder(event.organizationId, event.body);
    
    // Tạo dữ liệu ảo cho reminder
    final fakeReminder = service_detail.ServiceDetailModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      summary: "Nhắc hẹn: ${event.body.title} - ${event.body.content}",
      createdDate: DateTime.now().toIso8601String(),
      createdByName: "Bạn", // Có thể lấy từ user info
      type: "REMINDER",
      icon: "🔔",
    );

    // Thêm reminder mới vào đầu danh sách serviceDetails
    final updatedServiceDetails = List<service_detail.ServiceDetailModel>.from(state.serviceDetails)
      ..insert(0, fakeReminder);

    emit(state.copyWith(
      status: CustomerServiceStatus.success,
      serviceDetails: updatedServiceDetails,
    ));

  } catch (e) {
    emit(state.copyWith(
      status: CustomerServiceStatus.error,
      error: e.toString(),
    ));
  }
}
```

### 2. Cập nhật _saveReminder trong AddReminderDialog

**File**: `lib/presentation/screens/customers/customer_detail/widgets/reminder/add_reminder_dialog.dart`

```dart
// Thêm imports
import 'package:source_base/data/models/reminder_service_body.dart' as reminder_body;
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_event.dart';

// Trong method _saveReminder
if (widget.editingReminder != null) {
  // await ref.read(reminderListProvider.notifier).updateReminder(data);
} else {
  // Tạo ReminderServiceBody từ data
  final reminderBody = reminder_body.ReminderServiceBody(
    title: _titleController.text.trim(),
    content: _contentController.text.trim(),
    startTime: '${startDateTimeUtc.toIso8601String().substring(0, 23)}Z',
    endTime: endDateTimeUtc != null ? '${endDateTimeUtc.toIso8601String().substring(0, 23)}Z' : null,
    repeatRule: <reminder_body.RepeatRule>[],
    isDone: _isDone,
    schedulesType: _selectedType.id,
    priority: _selectedPriority.value,
    organizationId: widget.organizationId,
    workspaceId: widget.workspaceId,
    reminders: _notifyBeforeList.map((notify) {
      final totalMinutes = (notify['hour']! * 60) + notify['minute']!;
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return reminder_body.Reminders(
        time: '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}'
      );
    }).toList(),
    relatedProfiles: <reminder_body.RelatedProfiles>[],
    contact: _selectedContact != null ? [
      reminder_body.Contact(
        id: _selectedContact!['id'],
        fullName: _selectedContact!['fullName'],
        phone: _selectedContact!['phone'],
      )
    ] : null,
  );

  // Dispatch CreateReminder event
  context.read<CustomerServiceBloc>().add(
    CreateReminder(
      organizationId: widget.organizationId,
      body: reminderBody,
    ),
  );
}
```

## Cách hoạt động

### 1. Flow tạo Reminder

1. **User nhập thông tin** trong `AddReminderDialog`
2. **Click Save** → gọi method `_saveReminder()`
3. **Validate form** và tạo `ReminderServiceBody`
4. **Dispatch event** `CreateReminder` với data
5. **Bloc xử lý** event và tạo dữ liệu ảo
6. **Cập nhật state** với reminder mới ở đầu danh sách
7. **UI tự động update** hiển thị reminder mới

### 2. Dữ liệu ảo được tạo

```dart
final fakeReminder = service_detail.ServiceDetailModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(), // ID duy nhất
  summary: "Nhắc hẹn: ${event.body.title} - ${event.body.content}", // Tiêu đề + nội dung
  createdDate: DateTime.now().toIso8601String(), // Thời gian tạo
  createdByName: "Bạn", // Tên người tạo
  type: "REMINDER", // Loại
  icon: "🔔", // Icon reminder
);
```

### 3. Hiển thị trong CustomerJourney

Reminder mới sẽ xuất hiện ở đầu danh sách `serviceDetails` trong `CustomerJourney` widget với:
- **Icon**: 🔔 (bell emoji)
- **Type**: "REMINDER"
- **Summary**: "Nhắc hẹn: [Title] - [Content]"
- **Created by**: "Bạn"
- **Created date**: Thời gian hiện tại

## Lợi ích

1. **UX tốt hơn**: Reminder xuất hiện ngay lập tức không cần reload
2. **Consistent**: Sử dụng cùng pattern với các event khác
3. **Scalable**: Dễ dàng thay thế bằng API thực tế sau này
4. **Debug friendly**: Có thể theo dõi qua Bloc state

## TODO cho tương lai

1. **API Integration**: Thay thế dữ liệu ảo bằng API thực tế
2. **Error Handling**: Xử lý lỗi khi API fail
3. **Loading States**: Thêm loading indicator khi tạo
4. **Validation**: Validate dữ liệu trước khi gửi
5. **User Info**: Lấy thông tin user thực tế thay vì "Bạn"

## Testing

Để test tính năng:

1. **Mở Customer Detail** → Customer Journey
2. **Click Add Reminder** (nếu có button)
3. **Nhập thông tin** reminder
4. **Click Save**
5. **Kiểm tra** reminder xuất hiện ở đầu danh sách
6. **Verify** thông tin hiển thị đúng

## Lưu ý

- **Import conflicts**: Sử dụng `as reminder_body` để tránh conflict với model cũ
- **State management**: Reminder được thêm vào đầu danh sách để dễ nhìn thấy
- **Temporary data**: Dữ liệu ảo sẽ mất khi reload app, cần API để persist 