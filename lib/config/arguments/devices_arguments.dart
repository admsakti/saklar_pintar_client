import 'package:flutter/material.dart';

import '../../features/database/models/device.dart';

class DevicesArguments {
  final BuildContext context;
  final List<Device> devices;

  DevicesArguments(
    this.context,
    this.devices,
  );
}
