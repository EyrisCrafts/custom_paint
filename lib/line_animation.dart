import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LineAnimationScreen extends StatefulWidget {
  const LineAnimationScreen({Key? key}) : super(key: key);

  @override
  _LineAnimationScreenState createState() => _LineAnimationScreenState();
}

class _LineAnimationScreenState extends State<LineAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController tickController;

  @override
  void initState() {
    super.initState();
    tickController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 4000));
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      tickController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
            animation: tickController,
            builder: (context, child) {
              return CustomPaint(
                painter: CustomTick(tickController.value),
                size: Size.square(ScreenUtil().screenWidth / 3),
              );
            }),
      ),
    );
  }
}

class CustomTick extends CustomPainter {
  double anim;

  CustomTick(this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.pink;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;
    paint.isAntiAlias = true;
    paint.strokeCap = StrokeCap.round;
    double width = size.width;
    double height = size.height;

    Path path = createAnimatedPath(
        Path()
          ..moveTo(0, height)
          ..lineTo(width, height)
          ..lineTo(width, 0)
          ..lineTo(0, 0)
          ..lineTo(0, height)
          ..addOval(Rect.fromCircle(
              center: Offset((width / 2), height / 2),
              radius: (width / 2) * 0.8)),
        anim);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Path createAnimatedPath(
  Path originalPath,
  double animationPercent,
) {
  // ComputeMetrics can only be iterated once!
  final totalLength = originalPath
      .computeMetrics()
      .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

  final currentLength = totalLength * animationPercent;

  return extractPathUntilLength(originalPath, currentLength);
}

Path extractPathUntilLength(
  Path originalPath,
  double length,
) {
  var currentLength = 0.0;

  final path = new Path();

  var metricsIterator = originalPath.computeMetrics().iterator;

  while (metricsIterator.moveNext()) {
    var metric = metricsIterator.current;

    var nextLength = currentLength + metric.length;

    final isLastSegment = nextLength > length;
    if (isLastSegment) {
      final remainingLength = length - currentLength;
      final pathSegment = metric.extractPath(0.0, remainingLength);

      path.addPath(pathSegment, Offset.zero);
      break;
    } else {
      // There might be a more efficient way of extracting an entire path
      final pathSegment = metric.extractPath(0.0, metric.length);
      path.addPath(pathSegment, Offset.zero);
    }

    currentLength = nextLength;
  }

  return path;
}
