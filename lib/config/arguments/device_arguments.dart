import 'package:flutter/material.dart';

import '../../features/database/models/device.dart';

class DeviceArguments {
  final BuildContext context;
  final Device device;
  final bool currentStatus;
  final bool currentOnline;
  final String currentRSSI;

  DeviceArguments(
    this.context,
    this.device,
    this.currentStatus,
    this.currentOnline,
    this.currentRSSI,
  );
}
