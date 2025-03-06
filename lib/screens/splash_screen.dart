import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_filexplorer/screens/home.dart';
import 'package:smart_filexplorer/utils/app_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/Lottie/AnimatedIcon.json",
              width: 350, height: 350),
          Text(
            "Smart FileXplorer",
            style: AppTheme.splashStyle,
          )
        ],
      ),
      nextScreen: Home(),
      splashIconSize: 500,
      backgroundColor: AppTheme.borderColor,
    );
  }
}
