import 'package:equatable/equatable.dart';

enum DemoStatus { initial, loading, success, error }

class DemoState extends Equatable {
  final DemoStatus status;
  final List<String> items;
  final String? selectedItem;
  final String? error;
  final int counter;
  final bool isVisible;

  const DemoState({
    this.status = DemoStatus.initial,
    this.items = const [],
    this.selectedItem,
    this.error,
    this.counter = 0,
    this.isVisible = true,
  });

  DemoState copyWith({
    DemoStatus? status,
    List<String>? items,
    String? selectedItem,
    String? error,
    int? counter,
    bool? isVisible,
  }) {
    return DemoState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      error: error ?? this.error,
      counter: counter ?? this.counter,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        selectedItem,
        error,
        counter,
        isVisible,
      ];
}
