import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 2),
      () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/MainBNB",
          (Route<dynamic> route) => false,
          arguments: context,
        );
      },
    );
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'lib/assets/images/logo_biru_putih.png',
            height: MediaQuery.of(context).size.width / 1.5,
            width: MediaQuery.of(context).size.width / 1.5,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
