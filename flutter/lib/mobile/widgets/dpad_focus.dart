import 'package:flutter/material.dart';

/// Adds D-pad focus and activation to widgets that only handle touch gestures.
class DpadFocus extends StatefulWidget {
  const DpadFocus({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<DpadFocus> createState() => _DpadFocusState();
}

class _DpadFocusState extends State<DpadFocus> {
  bool _showFocus = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (value) => setState(() => _showFocus = value),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          widget.onPressed();
          return null;
        }),
      },
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: _showFocus
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: widget.child,
      ),
    );
  }
}
