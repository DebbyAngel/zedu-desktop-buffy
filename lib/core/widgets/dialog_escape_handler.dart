import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps dialog content so the Escape key pops the route.
///
/// Use this around the `builder` child of every `showDialog` call so that
/// pressing Escape dismisses the dialog, matching desktop conventions.
class DialogEscapeHandler extends StatelessWidget {
  const DialogEscapeHandler({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.escape):
            () => Navigator.of(context, rootNavigator: true).maybePop(),
      },
      child: child,
    );
  }
}
