# Message BLoC Implementation

This directory contains the BLoC implementation for message/conversation functionality, converted from the original Riverpod implementation.

## Files Structure

```
lib/presentation/blocs/message/
├── message_event.dart      # Events for the message bloc
├── message_state.dart      # State for the message bloc
├── message_bloc.dart       # Main message bloc implementation
├── message_action.dart     # Exports for easy importing
├── message_providers.dart  # Provider widgets for different message types
└── README.md              # This documentation
```

## Models

### Conversation Model
Located in `lib/data/models/conversation_model.dart`

```dart
class Conversation extends Equatable {
  final String id;
  final String pageId;
  final String pageName;
  final String? pageAvatar;
  final String personId;
  final String personName;
  final String? personAvatar;
  final String snippet;
  final bool canReply;
  final bool isFileMessage;
  final DateTime updatedTime;
  final int gptStatus;
  final bool isRead;
  final String type;
  final String provider;
  final String status;
  final String? assignName;
  final String? assignAvatar;
  
  // ... methods
}
```

## Usage

### 1. Setup Provider

Wrap your widget tree with the appropriate provider:

```dart
// For ZALO messages
ZaloMessageProvider(
  child: YourWidget(),
)

// For FACEBOOK messages
FacebookMessageProvider(
  child: YourWidget(),
)

// For ALL messages
AllMessageProvider(
  child: YourWidget(),
)
```

### 2. Using in Widgets

```dart
class MessageListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        if (state.status == MessageStatus.loading) {
          return CircularProgressIndicator();
        }
        
        if (state.status == MessageStatus.error) {
          return Text('Error: ${state.error}');
        }
        
        return ListView.builder(
          itemCount: state.conversations.length,
          itemBuilder: (context, index) {
            final conversation = state.conversations[index];
            return ConversationTile(conversation: conversation);
          },
        );
      },
    );
  }
}
```

### 3. Dispatching Events

```dart
// Load conversations
context.read<MessageBloc>().add(LoadConversations(
  organizationId: 'your-org-id',
  provider: 'ZALO', // optional
  forceRefresh: false,
));

// Load more conversations
context.read<MessageBloc>().add(LoadMoreConversations(
  organizationId: 'your-org-id',
  provider: 'ZALO', // optional
));

// Select a conversation
context.read<MessageBloc>().add(SelectConversation(
  conversationId: 'conversation-id',
));

// Update read status
context.read<MessageBloc>().add(UpdateStatusRead(
  organizationId: 'your-org-id',
  conversationId: 'conversation-id',
));

// Assign conversation
context.read<MessageBloc>().add(AssignConversation(
  organizationId: 'your-org-id',
  conversationId: 'conversation-id',
  userId: 'user-id',
  assignName: 'User Name',
  assignAvatar: 'avatar-url',
));

// Setup Firebase listener
context.read<MessageBloc>().add(SetupFirebaseListener(
  organizationId: 'your-org-id',
  context: context,
));
```

### 4. Helper Functions

```dart
// Get bloc instance
final bloc = getMessageBloc(context);

// Get current state
final state = getMessageState(context);
```

## Events

- `LoadConversations`: Load initial conversations
- `LoadMoreConversations`: Load more conversations (pagination)
- `SelectConversation`: Select a conversation
- `UpdateStatusRead`: Mark conversation as read
- `AssignConversation`: Assign conversation to a user
- `UpdateConversation`: Update conversation data
- `AddConversation`: Add new conversation
- `ClearConversations`: Clear all conversations
- `SetupFirebaseListener`: Setup real-time Firebase listener

## States

- `MessageStatus.initial`: Initial state
- `MessageStatus.loading`: Loading conversations
- `MessageStatus.loadingMore`: Loading more conversations
- `MessageStatus.success`: Success state
- `MessageStatus.error`: Error state

## Firebase Integration

The Firebase listener is currently commented out and requires:
1. Add `firebase_database` dependency to `pubspec.yaml`
2. Uncomment the Firebase code in `message_bloc.dart`
3. Configure Firebase in your project

## Repository

The `MessageRepository` handles all API calls:
- `getConversationList()`: Get conversations
- `updateStatusReadRepos()`: Update read status
- `assignConversation()`: Assign conversation
- `getOData()`: Get organization data

## Migration from Riverpod

This BLoC implementation provides the same functionality as the original Riverpod implementation:

| Riverpod | BLoC |
|----------|------|
| `zaloMessageProvider` | `ZaloMessageProvider` |
| `facebookMessageProvider` | `FacebookMessageProvider` |
| `allMessageProvider` | `AllMessageProvider` |
| `ref.watch()` | `BlocBuilder` |
| `ref.read()` | `context.read()` |
| `state.notifier` | `context.read<MessageBloc>()` | 