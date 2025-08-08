import 'package:equatable/equatable.dart';

abstract class DemoAction extends Equatable {
  const DemoAction();

  @override
  List<Object?> get props => [];
}

class DemoShowSnackBar extends DemoAction {
  final String message;

  const DemoShowSnackBar(this.message);

  @override
  List<Object?> get props => [message];
}

class DemoNavigateToDetail extends DemoAction {
  final String itemId;

  const DemoNavigateToDetail(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DemoShowDialog extends DemoAction {
  final String title;
  final String content;

  const DemoShowDialog({
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [title, content];
}

class DemoShowLoading extends DemoAction {
  const DemoShowLoading();
}

class DemoHideLoading extends DemoAction {
  const DemoHideLoading();
}

class DemoShowError extends DemoAction {
  final String errorMessage;

  const DemoShowError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class DemoRefreshData extends DemoAction {
  const DemoRefreshData();
}

class DemoLogAction extends DemoAction {
  final String action;
  final Map<String, dynamic>? data;

  const DemoLogAction(this.action, {this.data});

  @override
  List<Object?> get props => [action, data];
}
