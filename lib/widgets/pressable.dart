import 'package:flutter/material.dart';

/// Wraps any tappable widget (button, icon button, card, list tile…) and adds
/// a smooth scale-down "press" animation: the child shrinks slightly while a
/// finger is down and springs back when released.
///
/// It uses a [Listener] (raw pointer events) instead of a [GestureDetector],
/// so it never competes in the gesture arena. The wrapped widget keeps its own
/// behaviour completely intact — `onPressed` / `onTap`, the Material ink
/// ripple, hit-testing, semantics, everything still works. You can therefore
/// wrap an existing `ElevatedButton`, `TextButton`, `IconButton`, or a
/// `GestureDetector` without changing how it responds.
///
/// Because the animation is a paint-time transform, it does not affect layout
/// (no reflow / size jump of neighbouring widgets).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.easeOut,
    this.enabled = true,
  });

  /// The widget to animate. Keeps its own tap handling.
  final Widget child;

  /// The scale factor applied while pressed (1.0 = no shrink). Defaults to a
  /// subtle 0.95.
  final double scale;

  /// How long the press / release transition takes.
  final Duration duration;

  /// The animation curve for the scale transition.
  final Curve curve;

  /// When false, no animation is applied (useful for disabled buttons).
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Listener observes pointer events without joining the gesture arena, so
      // the child's own gestures are never stolen.
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
