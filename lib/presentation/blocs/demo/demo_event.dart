import 'package:equatable/equatable.dart';

abstract class DemoEvent extends Equatable {
  const DemoEvent();

  @override
  List<Object?> get props => [];
}

class DemoInitialized extends DemoEvent {
  const DemoInitialized();
}

class DemoLoadItems extends DemoEvent {
  const DemoLoadItems();
}

class DemoAddItem extends DemoEvent {
  final String item;

  const DemoAddItem(this.item);

  @override
  List<Object?> get props => [item];
}

class DemoRemoveItem extends DemoEvent {
  final String item;

  const DemoRemoveItem(this.item);

  @override
  List<Object?> get props => [item];
}

class DemoSelectItem extends DemoEvent {
  final String item;

  const DemoSelectItem(this.item);

  @override
  List<Object?> get props => [item];
}

class DemoIncrementCounter extends DemoEvent {
  const DemoIncrementCounter();
}

class DemoDecrementCounter extends DemoEvent {
  const DemoDecrementCounter();
}

class DemoToggleVisibility extends DemoEvent {
  const DemoToggleVisibility();
}

class DemoReset extends DemoEvent {
  const DemoReset();
}

class DemoError extends DemoEvent {
  final String message;

  const DemoError(this.message);

  @override
  List<Object?> get props => [message];
}
