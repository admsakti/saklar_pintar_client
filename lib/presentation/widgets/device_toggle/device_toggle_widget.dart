import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/arguments/device_arguments.dart';
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
    _currentOnline = false;
    _currentStatus = false;
    _currentRSSI = 'N/A';
  }

  void _toggleSwitch(bool isCurrentlyOnline) {
    final newCommand = isCurrentlyOnline ? 'OFF' : 'ON';

    context.read<MQTTBloc>().add(
          SetDeviceState(
            macRoot: widget.device.meshNetwork.macRoot,
            nodeId: widget.device.nodeId,
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
    super.build(context); // wajib jika pakai keepAlive
    return BlocListener<MQTTBloc, MQTTState>(
      listener: (context, state) {
        if (state is MQTTConnected) {
          final matched = state.deviceStatuses.where(
            (ds) => ds.nodeId == widget.device.nodeId,
          );

          if (matched.isNotEmpty) {
            final Map<String, dynamic> statusMap =
                json.decode(matched.last.value);

            setState(() {
              _currentOnline = true;
            });

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
          }
        } else if (state is! MQTTConnected) {
          setState(() {
            _currentOnline = false;
          });
        }
      },
      child: Card(
        color: ColorConstants.cardBlueAppColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          onLongPress: () => _onDeviceDashboardLongPressed(context),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: GestureDetector(
                  onLongPress: () => _onDeviceDashboardLongPressed(context),
                  child: Text(
                    widget.device.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  onChanged: _currentOnline
                      ? (_) => _toggleSwitch(_currentStatus)
                      : null, // Nonaktifkan jika offline
                  activeColor: Colors.green,
                  inactiveThumbColor: _currentOnline ? Colors.red : Colors.grey,
                  inactiveTrackColor: _currentOnline
                      ? Colors.red.shade200
                      : Colors.grey.shade400,
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
                        return _currentOnline ? Colors.green : Colors.grey;
                      }
                      return _currentOnline ? Colors.red : Colors.grey;
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
                      Row(
                        children: [
                          const SizedBox(
                            width: 55,
                            child: Text(
                              "Status",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8, child: Text(":")),
                          SizedBox(
                            child: Text(
                              _currentOnline ? "Online" : "Offline",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 55,
                            child: Text(
                              "RSSI",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8, child: Text(":")),
                          SizedBox(
                            child: Text(
                              _currentRSSI,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 55,
                            child: Text(
                              "Role",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8, child: Text(":")),
                          SizedBox(
                            child: Text(
                              "${widget.device.role} (${widget.device.meshNetwork.name})",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _onDeviceDashboardLongPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/DeviceDashboard',
      arguments: DeviceArguments(
        context,
        widget.device,
        _currentStatus,
        _currentOnline,
        _currentRSSI,
      ),
    );
  }
}
