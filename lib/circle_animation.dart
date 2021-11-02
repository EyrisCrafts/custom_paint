import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CircleAnimationScreen extends StatefulWidget {
  static final String id = 'finding_matches_screen';

  const CircleAnimationScreen({Key? key}) : super(key: key);

  @override
  _CircleAnimationScreenState createState() => _CircleAnimationScreenState();
}

class _CircleAnimationScreenState extends State<CircleAnimationScreen>
    with TickerProviderStateMixin {
  _CircleAnimationScreenState();

  ValueNotifier<List<double>> _size = ValueNotifier([100.0, 90.0]);
  ValueNotifier<int> _count = ValueNotifier(0);
  double maxHeartSize = 100;

  //The circle persons that orbit
  double circleImageSize = 0;

  List<double> circleOpacities = [0.7, 0.5, 0.3, 0.2, 0.1];

  List<double> origin = [];

  double animationDyOffset = 0;

  List<double> waveNormalSizes = [
    ScreenUtil().screenWidth * 0.33,
    ScreenUtil().screenWidth * 0.44,
    ScreenUtil().screenWidth * 0.56,
    ScreenUtil().screenWidth * 0.73,
    ScreenUtil().screenWidth * 0.9,
  ];

  List<double> waveMaxSizes = [
    ScreenUtil().screenWidth * 0.37,
    ScreenUtil().screenWidth * 0.48,
    ScreenUtil().screenWidth * 0.67,
    ScreenUtil().screenWidth * 0.73,
    ScreenUtil().screenWidth * 0.9,
  ];

  //Get min and max Size
  getCircleSize() {
    return ScreenUtil().screenWidth * (0.22);
  }

  double heartMinSize = ScreenUtil().screenWidth * 0.22;
  double heartMaxSize = ScreenUtil().screenWidth * 0.24;

  bool onlyLoadMatches = false;
  bool matchesAcquired = false;
  bool timePeriodPassed = false;

  @override
  void initState() {
    super.initState();

    _size.value = [heartMaxSize, heartMinSize];
    //The orbit's size should not exceed the difference between the last two waves diameter
    circleImageSize = ((waveMaxSizes[4] - waveMaxSizes[3]) / 2) - 0.3;
    int orbitDuration = 18000;
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: orbitDuration));
    controller.repeat();

    orbit1 = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(110.0, 110 + 360.0, getWeight(16750, orbitDuration)),
    ]).animate(controller);

    orbit2 = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(60.0, 60 + 360.0, getWeight(16750, orbitDuration)),
    ]).animate(controller);

    orbit3 = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(315.0, 315.0 + 360, getWeight(16750, orbitDuration)),
    ]).animate(controller);

    orbit4 = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(260.0, 260.0 + 360, getWeight(16750, orbitDuration)),
    ]).animate(controller);

    orbitS5 = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(45.0, 45 - 360.0, getWeight(16750, orbitDuration)),
    ]).animate(controller);

    orbitS6 = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(225.0, 225 - 360.0, getWeight(16750, orbitDuration)),
    ]).animate(controller);

    orbitOpacityAnimation = TweenSequence([
      easyTween(0.0, 0.0, getWeight(1250, orbitDuration)),
      easyTween(0.0, 360.0, getWeight(13750, orbitDuration)),
      easyTween(0.0, 360.0, getWeight(3000, orbitDuration)),
    ]).animate(controller);

    int count = 0;
    origin = [
      (ScreenUtil().screenWidth / 2) - (circleImageSize / 2),
      (ScreenUtil().screenHeight / 2) - (circleImageSize / 2)
    ];

    int heartBeatTotal = 3110;
    heartController = AnimationController(
        vsync: this, duration: Duration(milliseconds: heartBeatTotal))
      ..repeat();
    heartSizeTween = TweenSequence([
      easyTween(0.0, heartMaxSize, getWeight(500, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),

      //Pause beat
      easyTween(heartMinSize, heartMinSize, getWeight(210, heartBeatTotal)),

      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),

      //Pause beat
      easyTween(heartMinSize, heartMinSize, getWeight(210, heartBeatTotal)),

      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),

      //Pause beat
      easyTween(heartMinSize, heartMinSize, getWeight(210, heartBeatTotal)),

      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMinSize, heartMaxSize, getWeight(180, heartBeatTotal)),
      easyTween(heartMaxSize, heartMinSize, getWeight(180, heartBeatTotal)),

      //Pause beat
      easyTween(heartMinSize, heartMinSize, getWeight(210, heartBeatTotal)),
    ]).animate(heartController);

    int totalWave = 9700;
    wavesController = AnimationController(
        vsync: this, duration: Duration(milliseconds: totalWave))
      ..repeat();

    int waveNumber = 0;
    wave1Tween = prepareTweenSequence(
        waveNumber,
        [
          easyTween(0.0, waveMaxSizes[waveNumber], getWeight(500, totalWave)),
          easyTween(waveMaxSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(300, totalWave)),
        ],
        totalWave,
        800);

    waveNumber = 1;

    wave2Tween = prepareTweenSequence(
        waveNumber,
        [
          easyTween(0.0, 0.0, getWeight(250, totalWave)),
          easyTween(0.0, waveMaxSizes[waveNumber], getWeight(500, totalWave)),
          easyTween(waveMaxSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(300, totalWave)),
        ],
        totalWave,
        1050);

    waveNumber = 2;
    wave3Tween = prepareTweenSequence(
        waveNumber,
        [
          easyTween(0.0, 0.0, getWeight(500, totalWave)),
          easyTween(0.0, waveMaxSizes[waveNumber], getWeight(500, totalWave)),
          easyTween(waveMaxSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(300, totalWave)),
        ],
        totalWave,
        1300);

    waveNumber = 3;
    wave4Tween = prepareTweenSequence(
        waveNumber,
        [
          easyTween(0.0, 0.0, getWeight(1000, totalWave)),
          easyTween(
              0.0, waveNormalSizes[waveNumber], getWeight(500, totalWave)),
          easyTween(waveNormalSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(8200, totalWave)),
        ],
        totalWave,
        1300,
        shouldBreathe: false);

    waveNumber = 4;
    wave5Tween = prepareTweenSequence(
        waveNumber,
        [
          easyTween(0.0, 0.0, getWeight(750, totalWave)),
          easyTween(
              0.0, waveNormalSizes[waveNumber], getWeight(500, totalWave)),
          easyTween(waveNormalSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(8450, totalWave)),
        ],
        totalWave,
        1300,
        shouldBreathe: false);
  }

  Animation<double> prepareTweenSequence(
      int waveNumber,
      List<TweenSequenceItem<double>> initialSetup,
      int totalDuration,
      int setupDuration,
      {bool shouldBreathe = true}) {
    List<TweenSequenceItem<double>> toReturn = initialSetup;
    if (shouldBreathe) {
      //One breathe is 2100 milliseconds
      // (Total duration - initialSetup) / BreatheDuration
      //One breathe duration is 2100
      int numberOfBreathes = ((totalDuration - setupDuration) / 2100).floor();
      int remainingTime = ((totalDuration - setupDuration) % 2100);
      for (int i = 0; i < numberOfBreathes; i++) {
        toReturn.addAll([
          //Pause
          easyTween(waveNormalSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(1500, totalDuration)),

          //Breathe
          easyTween(waveNormalSizes[waveNumber], waveMaxSizes[waveNumber],
              getWeight(300, totalDuration)),
          easyTween(waveMaxSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(300, totalDuration)),
        ]);
      }
      //Add the remainingTime as pause
      if (remainingTime != 0)
        toReturn.add(
          easyTween(waveNormalSizes[waveNumber], waveNormalSizes[waveNumber],
              getWeight(remainingTime, totalDuration)),
        );
    }

    return TweenSequence(toReturn).animate(wavesController);
  }

  TweenSequenceItem<double> easyTween(double begin, double end, double weight) {
    return TweenSequenceItem(
      tween: Tween<double>(begin: begin, end: end),
      weight: weight,
    );
  }

  late AnimationController heartController;
  late Animation<double> heartSizeTween;

  late AnimationController wavesController;

  late Animation<double> wave1Tween;

  late Animation<double> wave2Tween;

  late Animation<double> wave3Tween;

  late Animation<double> wave4Tween;

  late Animation<double> wave5Tween;

  // AnimationBuilder animation
  late AnimationController controller;
  late Animation<double> orbit1;
  late Animation<double> orbit2;
  late Animation<double> orbit3;
  late Animation<double> orbit4;

  late Animation<double> orbitS5;
  late Animation<double> orbitS6;
  late Animation<double> orbitOpacityAnimation;

  @override
  dispose() {
    heartController.dispose();
    wavesController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    circleImageSize = ((waveMaxSizes[4] - waveMaxSizes[3]) / 1.5);
    double topSpace = ScreenUtil().statusBarHeight + 2.h + 43.h;
    origin = [
      (ScreenUtil().screenWidth / 2) - (circleImageSize / 2),
      (ScreenUtil().screenHeight / 2) - (circleImageSize / 2) - topSpace / 2
    ];
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
              top: topSpace,
              height: ScreenUtil().screenHeight - topSpace,
              width: ScreenUtil().screenWidth,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  buildWave(wave1Tween, 0),
                  buildWave(wave2Tween, 1),
                  buildWave(wave3Tween, 2),
                  buildWave(wave4Tween, 3),
                  buildWave(wave5Tween, 4),
                  buildLastWaveOrbit(orbit1, '1'),
                  buildLastWaveOrbit(orbit2, '2'),
                  buildLastWaveOrbit(orbit3, '3'),
                  buildLastWaveOrbit(orbit4, '4'),
                  buildSecondLastWaveOrbit(orbitS5, '5'),
                  buildSecondLastWaveOrbit(orbitS6, '6'),
                  _buildHeartBeat(),
                ],
              )),
        ],
      ),
    );
  }

  buildLastWaveOrbit(Animation animation, String id) {
    return AnimatedBuilder(
      animation: controller,
      child: Container(
        height: circleImageSize,
        width: circleImageSize,
        alignment: Alignment.center,
        child: Icon(Icons.ac_unit, size: circleImageSize),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
      builder: (context, child) => Positioned(
        left: getOrbitX(animation.value, (waveMaxSizes[4]) / 2),
        top: getOrbitY(animation.value, (waveMaxSizes[4]) / 2),
        height: circleImageSize,
        width: circleImageSize,
        child: Opacity(
          opacity: getOpacityAnimation(orbitOpacityAnimation.value),
          child: child,
        ),
      ),
    );
  }

  buildSecondLastWaveOrbit(Animation animation, String id) {
    return AnimatedBuilder(
      animation: controller,
      child: Container(
        height: circleImageSize,
        width: circleImageSize,
        alignment: Alignment.center,
        child: Icon(Icons.ac_unit, size: circleImageSize),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
      builder: (context, child) => Positioned(
        left: getOrbitX(animation.value, (waveMaxSizes[3]) / 2),
        top: getOrbitY(animation.value, (waveMaxSizes[3]) / 2),
        height: circleImageSize,
        width: circleImageSize,
        child: Opacity(
          opacity: getOpacityAnimation(orbitOpacityAnimation.value),
          child: child,
        ),
      ),
    );
  }

  buildWave(Animation animation, circleNumber) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Positioned(
        height: animation.value,
        width: animation.value,
        child: Container(
          height: animation.value,
          width: animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(circleOpacities[circleNumber]),
          ),
        ),
      ),
    );
  }

  getWeight(int duration, int totalAnimationDuration) {
    return (duration / totalAnimationDuration) * 100;
  }

  getOpacityAnimation(double animationVal) {
    //Total Animation size Quarter of total
    double totalAnimation = 360 / 3;
    double newAnimVal = animationVal % totalAnimation;

    //New anim goes from 0 - 120
    if (newAnimVal < 40) {
      // 0 - 1
      //Translate to 0 to 1
      double translated = (newAnimVal % 40) / 40;
      return translated;
    }
    if (newAnimVal > 40 && newAnimVal < 80) {
      // 1 - 1
      return 1.0;
    }
    if (newAnimVal > 80) {
      //1 - 0
      //Translate to 0 to 1
      double translated = ((newAnimVal - 80) % 40) / 40;

      //Invert
      return 1 - translated;
    }

    return ((animationVal % 100) / 100) > 0.5
        ? 1 - ((animationVal % 100) / 100)
        : ((animationVal % 100) / 100);
  }

  getMaxSize(int index) {
    double padding = (ScreenUtil().screenWidth * 0.1);
    return ((ScreenUtil().screenWidth - maxHeartSize - padding) / 5) *
        (index + 1);
  }

  getOrbitX(double i, double radius) {
    return origin[0] + math.cos((math.pi * i) / 180) * radius;
  }

  getOrbitY(double i, double radius) {
    return origin[1] + math.sin((math.pi * i) / 180) * radius;
  }

  _buildHeartBeat() {
    return //Heart Beat Animation
        ValueListenableBuilder(
      valueListenable: _count,
      builder: (context, count, _) => ValueListenableBuilder<List<double>>(
        valueListenable: _size,
        builder: (context, size, child) => AnimatedPositioned(
          height: count == 0 ? 0 : size[1],
          width: count == 0 ? 0 : size[1],
          curve: Curves.bounceIn,
          duration: Duration(milliseconds: count == 0 ? 500 : 180),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: count == 0 ? 500 : 180),
            opacity: count == 0 ? 0 : 1,
            child: TweenAnimationBuilder<double>(
                tween: Tween(begin: size[0], end: size[1]),
                duration: Duration(milliseconds: count == 0 ? 500 : 180),
                curve: Curves.bounceIn,
                child: SvgPicture.asset(
                  "assets/main.svg",
                  fit: BoxFit.fitWidth,
                ),
                // curve: Curves.easeIn,
                onEnd: () async {
                  if (_count.value % 4 == 0) {
                    await Future.delayed(Duration(milliseconds: 210));
                  }

                  if (_count.value % 2 == 0)
                    _size.value = [heartMinSize, heartMaxSize];
                  else
                    _size.value = [heartMaxSize, heartMinSize];

                  _count.value = _count.value + 1;
                },
                builder: (context, width, child) {
                  return Container(
                    height: width,
                    width: width,
                    child: child,
                  );
                }),
          ),
        ),
      ),
    );
  }
}
