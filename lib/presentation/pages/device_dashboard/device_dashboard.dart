import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';
import '../../../features/database/bloc/device_schedule/device_schedule_bloc.dart';
import '../../../features/database/bloc/mesh_network/mesh_network_bloc.dart';
import '../../../features/database/models/device.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';

class DeviceDashboardPage extends StatefulWidget {
  final Device device;
  final bool currentStatus;
  final bool currentOnline;
  final String currentRSSI;

  const DeviceDashboardPage({
    super.key,
    required this.device,
    required this.currentStatus,
    required this.currentOnline,
    required this.currentRSSI,
  });

  @override
  State<DeviceDashboardPage> createState() => _DeviceDashboardPageState();
}

class _DeviceDashboardPageState extends State<DeviceDashboardPage> {
  final GlobalKey<CustomRefreshIndicatorState> _refreshKey =
      GlobalKey<CustomRefreshIndicatorState>();

  late bool _currentOnline;
  late bool _currentStatus;
  late String _currentRSSI;

  late TextEditingController _controllerDeviceName;
  bool _isEditingDeviceName = false;
  late final FocusNode _focusDeviceNameTextField;

  late TextEditingController _controllerMeshName;
  bool _isEditingMeshName = false;
  late final FocusNode _focusMeshNameTextField;

  List<Map<String, dynamic>> scheduleList = [];

  String? selectedState;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _currentOnline = widget.currentOnline;
    _currentStatus = widget.currentStatus;
    _currentRSSI = widget.currentRSSI;

    _controllerDeviceName = TextEditingController(
      text: widget.device.name,
    );
    _controllerMeshName = TextEditingController(
      text: widget.device.meshNetwork.name,
    );

    _focusDeviceNameTextField = FocusNode();
    _focusMeshNameTextField = FocusNode();
  }

  @override
  void dispose() {
    _controllerDeviceName.dispose();
    _controllerMeshName.dispose();

    _focusDeviceNameTextField.dispose();
    _focusMeshNameTextField.dispose();
    super.dispose();
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

  void _saveDeviceName() {
    final newDeviceName = _controllerDeviceName.text.trim();
    if (newDeviceName.isNotEmpty && newDeviceName != widget.device.name) {
      context.read<DeviceBloc>().add(
            UpdateDeviceName(
              id: widget.device.id!,
              name: newDeviceName,
            ),
          );
      setState(() {
        _isEditingDeviceName = false;
        _controllerDeviceName.text = newDeviceName;
      });
    }
  }

  void _saveMeshName() {
    final newMeshName = _controllerMeshName.text.trim();
    if (newMeshName.isNotEmpty &&
        newMeshName != widget.device.meshNetwork.name) {
      context.read<MeshNetworkBloc>().add(
            UpdateMeshNetworkName(
              id: widget.device.meshNetwork.id!,
              name: newMeshName,
            ),
          );
      setState(() {
        _isEditingMeshName = false;
        _controllerMeshName.text = newMeshName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MQTTBloc, MQTTState>(
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
            }
          },
        ),
        BlocListener<DeviceBloc, DeviceState>(
          listener: (context, state) {
            if (state is DeviceLoading) {
              const Center(child: CircularProgressIndicator());
            } else if (state is UpdateDeviceSuccess) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Update Device Name'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Device name successfully updated!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.read<MQTTBloc>().add(
                                  RequestDevicesData(
                                    macRoot: widget.device.meshNetwork.macRoot,
                                    command: 'getNodes',
                                  ),
                                );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is DeviceFailure) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Update Device Name'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Device name failed to update'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        BlocListener<MeshNetworkBloc, MeshNetworkState>(
          listener: (context, state) {
            if (state is MeshNetworkLoading) {
              const Center(child: CircularProgressIndicator());
            } else if (state is UpdateMeshNetworkSuccess) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Update Mesh Name'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Mesh name successfully updated!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.read<DeviceBloc>().add(GetDevices());
                            context.read<MQTTBloc>().add(
                                  RequestDevicesData(
                                    macRoot: widget.device.meshNetwork.macRoot,
                                    command: 'getNodes',
                                  ),
                                );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is MeshNetworkFailure) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Update Mesh Name'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Mesh name failed to update'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        BlocListener<DeviceScheduleBloc, DeviceScheduleState>(
          listener: (context, state) {
            if (state is DeviceScheduleLoading) {
              const Center(child: CircularProgressIndicator());
            } else if (state is DeviceScheduleLoaded) {
              setState(() {
                scheduleList = state.schedules
                    .map(
                      (s) => s.toDisplayMap(),
                    )
                    .toList();
              });
            } else if (state is SaveDeviceScheduleSuccess) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Add Device Schedule'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Device schedule successfully added!'),
                          Text("Dont forget to set the schedule to device"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is DeleteDeviceScheduleSuccess) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Delete Device Schedule'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Device schedule deleted successfully!'),
                          Text("Dont forget to set the schedule to device"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is DeviceScheduleFailure) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      backgroundColor: ColorConstants.lightBlueAppColor,
                      title: const Text('Device Schedule Failure'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Gagal: ${state.message}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: ColorConstants.blackAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.lightBlueAppColor,
          leading: Builder(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onBackButtonTapped(context),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
            ),
          ),
          title: const Text(
            "Device Dashboard",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            // Refresh manual dengan tombol
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                _refreshKey.currentState?.refresh(
                  draggingCurve: Curves.easeOutBack,
                );
              },
              tooltip: "Refresh Device",
            ),
            const SizedBox(width: 5),
          ],
        ),
        body: CustomRefreshIndicator(
          key: _refreshKey,
          onRefresh: () async {
            print("Home Req Device Data: ${widget.device.nodeId}");

            context.read<MQTTBloc>().add(
                  RequestDeviceData(
                    macRoot: widget.device.meshNetwork.macRoot,
                    nodeId: widget.device.nodeId,
                  ),
                );
          },
          builder: (BuildContext context, Widget child,
              IndicatorController controller) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final double pulledExtent = controller.value.clamp(0.0, 1.0);
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.blueAccent,
                          value: pulledExtent,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: pulledExtent * 60),
                      child: child,
                    ),
                  ],
                );
              },
            );
          },
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controllerDeviceName,
                                  enabled: true,
                                  readOnly: !_isEditingDeviceName,
                                  focusNode: _focusDeviceNameTextField,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  onTapOutside: (event) {
                                    setState(() {
                                      _controllerDeviceName.text =
                                          widget.device.name;
                                      _isEditingDeviceName = false;
                                    });
                                    _focusDeviceNameTextField.unfocus();
                                  },
                                  onSubmitted: (_) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor:
                                            ColorConstants.lightBlueAppColor,
                                        title: const Text(
                                          "Update Device Name",
                                        ),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Yakin ingin mengganti nama device?",
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll<Color>(
                                                Colors.green,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _controllerDeviceName.text =
                                                    widget.device.name;
                                                _isEditingDeviceName = false;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Tidak',
                                              style: TextStyle(
                                                color: ColorConstants
                                                    .blackAppColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll<Color>(
                                                Colors.red,
                                              ),
                                            ),
                                            onPressed: () {
                                              _saveDeviceName(); // simpan dan disable field
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Ya!',
                                              style: TextStyle(
                                                color: ColorConstants
                                                    .blackAppColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditingDeviceName = true;
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    _focusDeviceNameTextField.requestFocus();
                                    _controllerDeviceName.selection =
                                        TextSelection.collapsed(
                                      offset: _controllerDeviceName.text.length,
                                    );
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                iconSize: 24,
                                constraints: const BoxConstraints(),
                                tooltip: "Edit Device Name",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: _currentStatus,
                          onChanged: _currentOnline
                              ? (_) => _toggleSwitch(_currentStatus)
                              : null, // Nonaktifkan jika offline
                          activeColor: Colors.green,
                          inactiveThumbColor:
                              _currentOnline ? Colors.red : Colors.grey,
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
                          trackOutlineColor:
                              WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.green;
                              }
                              return _currentOnline ? Colors.red : Colors.grey;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text(
                            "Node ID",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8, child: Text(":")),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            widget.device.nodeId,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8, child: Text(":")),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            _currentOnline ? "Online" : "Offline",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text(
                            "RSSI",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8, child: Text(":")),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            _currentRSSI,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "Role",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8, child: Text(":")),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          widget.device.role,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "Mesh Name",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8, child: Text(":")),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controllerMeshName,
                                enabled: true,
                                readOnly: !_isEditingMeshName,
                                focusNode: _focusMeshNameTextField,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                onTapOutside: (event) {
                                  setState(() {
                                    _controllerMeshName.text =
                                        widget.device.meshNetwork.name;
                                    _isEditingMeshName = false;
                                  });
                                  _focusDeviceNameTextField.unfocus();
                                },
                                onSubmitted: (_) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor:
                                          ColorConstants.lightBlueAppColor,
                                      title: const Text(
                                        "Update Mesh Name",
                                      ),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Yakin ingin mengganti nama mesh?",
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                              Colors.green,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _controllerMeshName.text = widget
                                                  .device.meshNetwork.name;
                                              _isEditingMeshName = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Tidak',
                                            style: TextStyle(
                                              color:
                                                  ColorConstants.blackAppColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                              Colors.red,
                                            ),
                                          ),
                                          onPressed: () {
                                            _saveMeshName(); // simpan dan disable field
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Ya!',
                                            style: TextStyle(
                                              color:
                                                  ColorConstants.blackAppColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingMeshName = true;
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _focusMeshNameTextField.requestFocus();
                                  _controllerMeshName.selection =
                                      TextSelection.collapsed(
                                    offset: _controllerMeshName.text.length,
                                  );
                                });
                              },
                              icon: const Icon(Icons.edit),
                              iconSize: 20,
                              constraints: const BoxConstraints(),
                              tooltip: "Edit Mesh Name",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text(
                            "Mesh Address",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8, child: Text(":")),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            widget.device.meshNetwork.macRoot,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: ColorConstants.darkBlueAppColor,
                    thickness: 2,
                    height: 32,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Device Schedule",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _openDeviceTimePicker(context),
                              icon:
                                  const Icon(Icons.add_circle_outline_rounded),
                              tooltip: "Add Device Schedule",
                            ),
                          ],
                        ),
                        const Divider(thickness: 1),
                        // Table Header
                        const Row(
                          children: [
                            SizedBox(width: 40), // icon delete space
                            Expanded(child: Center(child: Text("Time"))),
                            Expanded(child: Center(child: Text("State"))),
                            Expanded(child: Center(child: Text("Enabled"))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Cek apakah scheduleList kosong
                        if (scheduleList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    "Timer schedule kosong",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _openDeviceTimePicker(context),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                    ),
                                    tooltip: "Add Device Schedule",
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...scheduleList.asMap().entries.map(
                            (entry) {
                              int index = entry.key;
                              var item = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    // Delete button
                                    SizedBox(
                                      width: 40,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            scheduleList.removeAt(index);
                                          });

                                          context
                                              .read<DeviceScheduleBloc>()
                                              .add(
                                                DeleteDeviceSchedule(
                                                  scheduleId:
                                                      item["scheduleId"],
                                                ),
                                              );
                                        },
                                        icon: const Icon(Icons.delete),
                                        iconSize: 20,
                                      ),
                                    ),
                                    // Time
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          item["time"],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    // State
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          item["state"],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    // Toggle switch
                                    Expanded(
                                      child: Center(
                                        child: Switch(
                                          value: item["enabled"],
                                          onChanged: (value) {
                                            setState(() {
                                              scheduleList[index]["enabled"] =
                                                  value;
                                            });

                                            context
                                                .read<DeviceScheduleBloc>()
                                                .add(
                                                  UpdateDeviceScheduleEnabled(
                                                    scheduleId:
                                                        item["scheduleId"],
                                                    enabled: value,
                                                  ),
                                                );
                                          },
                                          activeColor: Colors.green,
                                          inactiveThumbColor: Colors.red,
                                          inactiveTrackColor:
                                              Colors.red.shade200,
                                          thumbIcon: WidgetStateProperty
                                              .resolveWith<Icon?>(
                                                  (Set<WidgetState> states) {
                                            if (states.contains(
                                                WidgetState.selected)) {
                                              return const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                              );
                                            }
                                            return const Icon(
                                              Icons.close_rounded,
                                              color: Colors.black54,
                                            );
                                          }),
                                          trackOutlineColor: WidgetStateProperty
                                              .resolveWith<Color?>(
                                            (Set<WidgetState> states) {
                                              if (states.contains(
                                                  WidgetState.selected)) {
                                                return Colors.green;
                                              }
                                              return Colors.red;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        // SET Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: !_currentOnline ||
                                  scheduleList.isEmpty ||
                                  !scheduleList
                                      .any((item) => item['enabled'] == true)
                              ? null // tombol disable
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor:
                                          ColorConstants.lightBlueAppColor,
                                      title: const Text(
                                        "Set Device Schedule",
                                      ),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              "Yakin ingin menambahkan Schedule ini ke Device?"),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                              Colors.green,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Tidak',
                                            style: TextStyle(
                                              color:
                                                  ColorConstants.blackAppColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                              Colors.red,
                                            ),
                                          ),
                                          onPressed: () =>
                                              _onSetDeviceSchedule(context),
                                          child: Text(
                                            'Ya!',
                                            style: TextStyle(
                                              color:
                                                  ColorConstants.blackAppColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          child: const Text(
                            "SET SCHEDULE",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDeviceTimePicker(BuildContext context) {
    BottomPicker.time(
      pickerTitle: Text(
        'Set your Device State Schedule',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: ColorConstants.darkBlueAppColor,
        ),
      ),
      use24hFormat: true,
      showTimeSeparator: true,
      initialTime: Time(hours: 0, minutes: 0),
      bottomPickerTheme: BottomPickerTheme.blue,
      onSubmit: (time) {
        final jam = DateTime.parse(time.toString());
        print('Time picked: ${jam.hour}:${jam.minute}');

        selectedTime = TimeOfDay(hour: jam.hour, minute: jam.minute);

        // Setelah selesai, buka picker berikutnya
        Future.delayed(const Duration(milliseconds: 300), () {
          _openDeviceStatePicker(context);
        });
      },
      onCloseButtonPressed: () {
        selectedTime = null;
        print('Time picker closed');
      },
    ).show(context);
  }

  void _openDeviceStatePicker(BuildContext context) {
    BottomPicker(
      items: const [
        Center(child: Text('OFF')),
        Center(child: Text('ON')),
      ],
      selectedItemIndex: 0,
      pickerTitle: Text(
        'Select Device State',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: ColorConstants.darkBlueAppColor,
        ),
      ),
      bottomPickerTheme: BottomPickerTheme.plumPlate,
      onSubmit: (index) {
        selectedState = index == 0 ? 'OFF' : 'ON';
        print('Selected: $selectedState');

        if (selectedTime != null && selectedState != null) {
          // Simpan ke list
          setState(() {
            scheduleList.add({
              'time':
                  '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
              'state': selectedState!,
              'enabled': true
            });
          });

          context.read<DeviceScheduleBloc>().add(
                InsertDeviceSchedulewithDeviceId(
                  deviceId: widget.device.id!,
                  time:
                      '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  state: selectedState!,
                  enabled: true,
                ),
              );

          // Cetak sebagai JSON
          print(jsonEncode(scheduleList));
        }
      },
      onCloseButtonPressed: () {
        selectedState = null;

        // Jika ditutup, kembali ke picker sebelumnya
        Future.delayed(const Duration(milliseconds: 300), () {
          _openDeviceTimePicker(context);
        });

        print('Device state picker closed');
      },
    ).show(context);
  }

  void _onSetDeviceSchedule(BuildContext context) {
    // Filter hanya yang enabled, lalu ambil hanya 'time' dan 'state'
    List<Map<String, String>> filteredScheduleList = scheduleList
        .where((item) => item['enabled'] == true)
        .map((item) => {
              "time": item["time"].toString(),
              "state": item["state"].toString(),
            })
        .toList();

    String strfilteredScheduleList = jsonEncode(filteredScheduleList);

    print(strfilteredScheduleList);

    context.read<MQTTBloc>().add(
          SetDeviceSchedule(
            macRoot: widget.device.meshNetwork.macRoot,
            nodeId: widget.device.nodeId,
            scheduleList: strfilteredScheduleList,
          ),
        );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: ColorConstants.lightBlueAppColor,
            title: const Text('Send Device Schedule'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mengirimkan schedule ke device!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: ColorConstants.blackAppColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }
}
