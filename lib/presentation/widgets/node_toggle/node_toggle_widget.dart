import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';

class NodeToggleWidget extends StatelessWidget {
  final String roomName;
  final bool isOnline;
  final Color indicatorColor;
  final VoidCallback? onTap;

  const NodeToggleWidget({
    super.key,
    required this.roomName,
    required this.isOnline,
    required this.indicatorColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstants.cardBlueAppColor, // Background biru muda
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          roomName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Switch(
          value: isOnline,
          onChanged: (_) => onTap?.call(),
          activeColor: indicatorColor,
        ),
      ),
    );
  }
}
