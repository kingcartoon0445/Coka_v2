import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'demo_event.dart';
import 'demo_state.dart';
import 'demo_action.dart';

class DemoBloc extends Bloc<DemoEvent, DemoState> {
  DemoBloc() : super(const DemoState()) {
    on<DemoInitialized>(_onInitialized);
    on<DemoLoadItems>(_onLoadItems);
    on<DemoAddItem>(_onAddItem);
    on<DemoRemoveItem>(_onRemoveItem);
    on<DemoSelectItem>(_onSelectItem);
    on<DemoIncrementCounter>(_onIncrementCounter);
    on<DemoDecrementCounter>(_onDecrementCounter);
    on<DemoToggleVisibility>(_onToggleVisibility);
    on<DemoReset>(_onReset);
    on<DemoError>(_onError);
  }

  // Stream controller for actions
  final StreamController<DemoAction> _actionController =
      StreamController<DemoAction>.broadcast();
  Stream<DemoAction> get actionStream => _actionController.stream;

  void _addAction(DemoAction action) {
    _actionController.add(action);
  }

  Future<void> _onInitialized(
    DemoInitialized event,
    Emitter<DemoState> emit,
  ) async {
    emit(state.copyWith(status: DemoStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final initialItems = ['Item 1', 'Item 2', 'Item 3'];
      emit(state.copyWith(
        status: DemoStatus.success,
        items: initialItems,
      ));

      _addAction(const DemoShowSnackBar('Demo initialized successfully!'));
    } catch (e) {
      emit(state.copyWith(
        status: DemoStatus.error,
        error: 'Failed to initialize demo',
      ));
    }
  }

  Future<void> _onLoadItems(
    DemoLoadItems event,
    Emitter<DemoState> emit,
  ) async {
    emit(state.copyWith(status: DemoStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final newItems = ['New Item 1', 'New Item 2', 'New Item 3', 'New Item 4'];
      emit(state.copyWith(
        status: DemoStatus.success,
        items: newItems,
      ));

      _addAction(const DemoShowSnackBar('Items loaded successfully!'));
    } catch (e) {
      emit(state.copyWith(
        status: DemoStatus.error,
        error: 'Failed to load items',
      ));
    }
  }

  void _onAddItem(
    DemoAddItem event,
    Emitter<DemoState> emit,
  ) {
    final updatedItems = List<String>.from(state.items)..add(event.item);
    emit(state.copyWith(items: updatedItems));

    _addAction(DemoShowSnackBar('Added: ${event.item}'));
    _addAction(DemoLogAction('add_item', data: {'item': event.item}));
  }

  void _onRemoveItem(
    DemoRemoveItem event,
    Emitter<DemoState> emit,
  ) {
    final updatedItems = List<String>.from(state.items)..remove(event.item);
    emit(state.copyWith(items: updatedItems));

    _addAction(DemoShowSnackBar('Removed: ${event.item}'));
    _addAction(DemoLogAction('remove_item', data: {'item': event.item}));
  }

  void _onSelectItem(
    DemoSelectItem event,
    Emitter<DemoState> emit,
  ) {
    emit(state.copyWith(selectedItem: event.item));

    _addAction(DemoNavigateToDetail(event.item));
    _addAction(DemoLogAction('select_item', data: {'item': event.item}));
  }

  void _onIncrementCounter(
    DemoIncrementCounter event,
    Emitter<DemoState> emit,
  ) {
    final newCounter = state.counter + 1;
    emit(state.copyWith(counter: newCounter));

    if (newCounter % 5 == 0) {
      _addAction(DemoShowDialog(
        title: 'Milestone!',
        content: 'Counter reached: $newCounter',
      ));
    }
  }

  void _onDecrementCounter(
    DemoDecrementCounter event,
    Emitter<DemoState> emit,
  ) {
    final newCounter = state.counter - 1;
    if (newCounter >= 0) {
      emit(state.copyWith(counter: newCounter));
    } else {
      _addAction(const DemoShowError('Counter cannot be negative!'));
    }
  }

  void _onToggleVisibility(
    DemoToggleVisibility event,
    Emitter<DemoState> emit,
  ) {
    final newVisibility = !state.isVisible;
    emit(state.copyWith(isVisible: newVisibility));

    _addAction(DemoShowSnackBar(
        newVisibility ? 'Visibility enabled' : 'Visibility disabled'));
  }

  void _onReset(
    DemoReset event,
    Emitter<DemoState> emit,
  ) {
    emit(const DemoState());
    _addAction(const DemoShowSnackBar('Demo reset successfully!'));
  }

  void _onError(
    DemoError event,
    Emitter<DemoState> emit,
  ) {
    emit(state.copyWith(
      status: DemoStatus.error,
      error: event.message,
    ));

    _addAction(DemoShowError(event.message));
  }

  @override
  Future<void> close() {
    _actionController.close();
    return super.close();
  }
}
