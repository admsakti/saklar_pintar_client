import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/models/device.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';

class DeviceToggleWidget extends StatefulWidget {
  final Device device;

  const DeviceToggleWidget({
    super.key,
    required this.device,
  });

  @override
  State<DeviceToggleWidget> createState() => _DeviceToggleWidgetState();
}

class _DeviceToggleWidgetState extends State<DeviceToggleWidget>
    with AutomaticKeepAliveClientMixin {
  late bool _currentOnline;
  late bool _currentStatus;
  late String _currentRSSI;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // sepertinya aman, karena pas refresh data akan diminta ulang dari root!!
    _currentOnline = false;
    _currentStatus = false;
    _currentRSSI = 'N/A';
  }

  void _toggleSwitch(bool isCurrentlyOnline) {
    final newCommand = isCurrentlyOnline ? 'OFF' : 'ON';

    context.read<MQTTBloc>().add(
          SetDeviceState(
            macRoot: widget.device.meshNetwork.macRoot,
            deviceId: widget.device.deviceId,
            value: newCommand,
          ),
        );

    setState(() {
      _currentStatus = !_currentStatus;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // penting untuk memanggil super.build saat pakai keepAlive
    return BlocListener<MQTTBloc, MQTTState>(
      listener: (context, state) {
        if (state is MQTTConnected) {
          final matched = state.deviceStatuses.where(
            (ds) => ds.nodeId == widget.device.deviceId,
          );

          if (matched.isNotEmpty) {
            final Map<String, dynamic> statusMap =
                json.decode(matched.last.value);

            if (statusMap.containsKey('rssi')) {
              final signalStrength = (statusMap['rssi']).toString();
              setState(() {
                _currentRSSI = signalStrength;
              });
            }

            if (statusMap.containsKey('status')) {
              final currentStatus =
                  (statusMap['status']).toString().toUpperCase() == 'ON';
              setState(() {
                _currentStatus = currentStatus;
              });
            }

            setState(() {
              _currentOnline = true;
            });
          }
        }
      },
      child: Card(
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
                    widget.device.name,
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
                  value: _currentStatus,
                  onChanged: (_) => _toggleSwitch(_currentStatus),
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
              ),
              if (_isExpanded)
                Container(
                  margin: const EdgeInsets.only(left: 55, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${_currentOnline ? "Online" : "Offline"}'),
                      Text('Signal strength: $_currentRSSI'),
                      Text(
                          'Mesh name: ${widget.device.meshNetwork.name} - (${widget.device.role})'),
                    ],
                  ),
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}
