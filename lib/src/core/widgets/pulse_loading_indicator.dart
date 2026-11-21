import 'package:material_ui/material_ui.dart';

/// Pure-Flutter animated pulse indicator matching the original SpinKitPulse look.
class PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulseLoadingIndicator({
    super.key,
    this.color = Colors.blue,
    this.size = 50.0,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _curvedAnimation,
        builder: (BuildContext context, Widget? child) {
          final double value = _curvedAnimation.value;
          return Opacity(
            opacity: (1.0 - value).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: value,
              child: child,
            ),
          );
        },
        child: SizedBox.square(
          dimension: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
