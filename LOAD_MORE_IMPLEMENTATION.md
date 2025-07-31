# Load More Implementation for ServiceDetails

## Overview
This implementation adds pagination support for `serviceDetails` based on the `ServiceDetailResponse` model. The load more functionality allows users to scroll through large lists of service details efficiently.

## Changes Made

### 1. State Updates (`customer_service_state.dart`)
- Added `serviceDetailsMetadata` field to store pagination metadata
- Added `hasMoreServiceDetails` boolean to track if more data is available
- Added `loadingMore` status to distinguish between initial loading and load more operations

### 2. Event Updates (`customer_service_event.dart`)
- Added `LoadMoreServiceDetails` event with parameters:
  - `organizationId`: Organization identifier
  - `limit`: Number of items to load per page
  - `offset`: Starting position for pagination

### 3. Bloc Updates (`customer_service_bloc.dart`)
- Enhanced `_onLoadJourneyPaging` method to calculate `hasMoreServiceDetails`
- Added `_onLoadMoreServiceDetails` method to handle pagination
- Updated to append new items to existing list instead of replacing

### 4. API Layer Updates
- Modified `getJourneyPagingService` in `api_service.dart` to support `limit` and `offset` parameters
- Updated `getLeadPagingArchive` in `organization_repository.dart` to pass pagination parameters

### 5. UI Widget (`service_details_list_widget.dart`)
- Created reusable widget with scroll detection
- Automatically triggers load more when user scrolls near bottom
- Shows loading indicators for both initial load and load more operations
- Handles error states with retry functionality

## Usage Example

```dart
// In your screen/widget
BlocProvider<CustomerServiceBloc>(
  create: (context) => CustomerServiceBloc(
    organizationRepository: context.read<OrganizationRepository>(),
    calendarRepository: context.read<CalendarRepository>(),
  ),
  child: ServiceDetailsListWidget(
    organizationId: 'your-org-id',
    customerId: 'customer-id',
    pageSize: 20,
  ),
)
```

## How It Works

1. **Initial Load**: When the widget is first loaded, it triggers `LoadJourneyPaging` event
2. **Scroll Detection**: The widget monitors scroll position and triggers load more when user reaches near bottom
3. **Pagination Calculation**: The system calculates if more data is available using metadata from the API response
4. **State Management**: New items are appended to the existing list, maintaining scroll position
5. **Loading States**: Different loading indicators are shown for initial load vs load more operations

## API Response Structure

The implementation expects the API to return data in this format:
```json
{
  "code": 200,
  "content": [...],
  "metadata": {
    "total": 100,
    "count": 20,
    "offset": 0,
    "limit": 20
  }
}
```

## Key Features

- **Efficient Memory Usage**: Only loads data as needed
- **Smooth UX**: Maintains scroll position during load more
- **Error Handling**: Graceful error handling with retry options
- **Loading States**: Clear visual feedback for different loading states
- **Configurable**: Page size can be customized per use case

## Testing

To test the load more functionality:
1. Ensure you have a large dataset (more than one page)
2. Scroll to the bottom of the list
3. Verify that new items are loaded automatically
4. Check that loading indicators appear appropriately
5. Test error scenarios and retry functionality 