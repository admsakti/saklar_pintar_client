import 'package:flutter/material.dart';

class NodeCardWidget extends StatelessWidget {
  final String deviceName;
  final bool isOnline;
  final String signalStrength;
  final String meshName;
  final Color indicatorColor;

  const NodeCardWidget({
    super.key,
    required this.deviceName,
    required this.isOnline,
    required this.signalStrength,
    required this.meshName,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicator
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${isOnline ? "Online" : "Offline"}'),
                  Text('Signal strength: $signalStrength'),
                  Text('Mesh name: $meshName'),
                ],
              ),
            ),
            // Optional icon
            Icon(
              isOnline ? Icons.check_circle : Icons.cancel,
              color: isOnline ? Colors.green : Colors.red,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
