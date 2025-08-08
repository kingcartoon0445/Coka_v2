import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/repositories/message_repository.dart';
import 'package:source_base/presentation/blocs/message/message_bloc.dart';
import 'package:source_base/presentation/blocs/message/message_state.dart';

// Provider cho ZALO messages
class ZaloMessageProvider extends StatelessWidget {
  final Widget child;

  const ZaloMessageProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageBloc>(
      create: (context) => MessageBloc(
        repository: MessageRepository(DioClient()),
        defaultProvider: 'ZALO',
      ),
      child: child,
    );
  }
}

// Provider cho FACEBOOK messages
class FacebookMessageProvider extends StatelessWidget {
  final Widget child;

  const FacebookMessageProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageBloc>(
      create: (context) => MessageBloc(
        repository: MessageRepository(DioClient()),
        defaultProvider: 'FACEBOOK',
      ),
      child: child,
    );
  }
}

// Provider cho ALL messages
class AllMessageProvider extends StatelessWidget {
  final Widget child;

  const AllMessageProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageBloc>(
      create: (context) => MessageBloc(
        repository: MessageRepository(DioClient()),
        defaultProvider: null, // null means all providers
      ),
      child: child,
    );
  }
}

// Helper function to get MessageBloc from context
MessageBloc getMessageBloc(BuildContext context) {
  return context.read<MessageBloc>();
}

// Helper function to get MessageState from context
MessageState getMessageState(BuildContext context) {
  return context.watch<MessageBloc>().state;
}
