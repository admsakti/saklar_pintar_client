import 'package:flutter/material.dart';
import 'package:graphite/graphite.dart';

import '../../../features/database/models/device.dart';

class NodeDeviceInfoGraph {
  final NodeInput node;
  final Rect rect;
  final Device data;

  NodeDeviceInfoGraph({
    required this.node,
    required this.rect,
    required this.data,
  });
}
