import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        title: const Text('Settings'),
      ),
    );
  }
}
