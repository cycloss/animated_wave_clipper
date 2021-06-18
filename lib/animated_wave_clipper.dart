library animated_wave_clipper;

import 'package:flutter/widgets.dart';

class AnimatedWaveClipper extends StatefulWidget {
  /// [child] is the widget that will be clipped by the wave, usually but not always a colored `Container`.
  /// [duration] is *roughly* the time it takes for a wave to complete a single animation cycle.
  /// [waveXOffset] is the phase shift of the wave, which must be between 0 (inclusive) and 1 (exclusive).
  /// [waveHeight] is the amplitude of the wave, which must be between 0 (inclusive) and 1 (inclusive). 0 is no height, and 1 is full height.
  AnimatedWaveClipper(
      {Key? key,
      required Widget child,
      duration = const Duration(seconds: 2),
      double waveXOffset = 0,
      double waveHeight = 0.5})
      : _child = child,
        _duration = duration,
        _waveXOffset = waveXOffset,
        _waveHeight = waveHeight,
        super(key: key) {
    if (waveXOffset >= 1 || waveXOffset < 0) {
      throw ArgumentError(
          'offset must be between 0 (inclusive) and 1 (exclusive)');
    }
    if (waveXOffset >= 1 || waveXOffset < 0) {
      throw ArgumentError(
          'wave height must be between 0 (inclusive) and 1 (exclusive)');
    }
  }
  final Widget _child;
  final Duration _duration;
  final double _waveXOffset;
  final double _waveHeight;

  @override
  _AnimatedWaveClipperState createState() => _AnimatedWaveClipperState();
}

class _AnimatedWaveClipperState extends State<AnimatedWaveClipper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        duration: widget._duration, // duration is the speed of the animation
        vsync: this);
    _ac.value = widget._waveXOffset;
    _ac.repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, child) {
        return ClipPath(
            clipper: WaveClipper(_ac.value, widget._waveHeight),
            child: widget._child);
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  double animationValue;
  double waveHeight;
  WaveClipper(this.animationValue, this.waveHeight);

  @override
  Path getClip(Size size) {
    var path = Path();
    var width = size.width;
    var height = size.height;

    path.moveTo(2 * -width, height);
    path.lineTo(2 * -width, height * 0.5);

    // * 2 because line goes half way to bezier attractor
    var amplitude = (1 - waveHeight * 2) * height * 0.5;

    // control point
    var c0 = Offset(1.5 * -width, height - amplitude);
    // end point
    var e0 = Offset(-width, height * 0.5);
    path.quadraticBezierTo(c0.dx, c0.dy, e0.dx, e0.dy);

    // control point
    var c1 = Offset(-width / 2, 0 + amplitude);
    // end point
    var e1 = Offset(0, height * 0.5);
    path.quadraticBezierTo(c1.dx, c1.dy, e1.dx, e1.dy);

    // control point
    var c2 = Offset(width / 2, height - amplitude);
    // end point
    var e2 = Offset(width, height * 0.5);
    path.quadraticBezierTo(c2.dx, c2.dy, e2.dx, e2.dy);
    path.lineTo(width, height);
    path.close();

    // animation offset, 0 - 1

    var offset = Offset(size.width * 2 * animationValue, 0);
    return path.shift(offset);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
