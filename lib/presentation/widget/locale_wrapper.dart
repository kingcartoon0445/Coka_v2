import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/presentation/blocs/theme/theme_bloc.dart';
import 'package:source_base/presentation/blocs/theme/theme_state.dart';

/// Wrapper widget để force rebuild khi locale thay đổi
class LocaleWrapper extends StatelessWidget {
  final Widget child;

  const LocaleWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) =>
          previous.currentLocale != current.currentLocale,
      builder: (context, state) {
        return KeyedSubtree(
          key: ValueKey(state.currentLocale.toString()),
          child: child,
        );
      },
    );
  }
}
