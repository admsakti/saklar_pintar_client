import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';

class DeviceToggleWidget extends StatefulWidget {
  final String deviceName;
  final bool isOnline;
  final String signalStrength;
  final String meshName;
  final Color indicatorColor;
  final VoidCallback? onTap;

  const DeviceToggleWidget({
    super.key,
    required this.deviceName,
    required this.isOnline,
    required this.signalStrength,
    required this.meshName,
    required this.indicatorColor,
    this.onTap,
  });

  @override
  State<DeviceToggleWidget> createState() => _DeviceToggleWidgetState();
}

class _DeviceToggleWidgetState extends State<DeviceToggleWidget> {
  late bool _currentOnline;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentOnline = widget.isOnline;
  }

  void _toggleSwitch() {
    setState(() {
      _currentOnline = !_currentOnline;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstants.cardBlueAppColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: GestureDetector(
                onLongPress: () {
                  print('mantap');
                },
                child: Text(
                  widget.deviceName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              leading: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 24,
                ),
              ),
              trailing: Switch(
                value: _currentOnline,
                onChanged: (_) => _toggleSwitch(),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.shade200,
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.white,
                    );
                  }
                  return const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.black54,
                  );
                }),
                trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.green;
                    }
                    return Colors.red;
                  },
                ),
              ),
              // isThreeLine: true,
            ),
            if (_isExpanded)
              Container(
                margin: const EdgeInsets.only(left: 55, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${_currentOnline ? "Online" : "Offline"}'),
                    Text('Signal strength: ${widget.signalStrength}'),
                    Text('Mesh name: ${widget.meshName}'),
                  ],
                ),
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }
}
