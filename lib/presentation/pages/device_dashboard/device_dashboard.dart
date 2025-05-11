import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';

import '../../../../core/constants/color_constants.dart';
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
  late bool _currentOnline;
  late bool _currentStatus;
  late String _currentRSSI;

  @override
  void initState() {
    super.initState();
    _currentOnline = widget.currentOnline;
    _currentStatus = widget.currentStatus;
    _currentRSSI = widget.currentRSSI;
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
  Widget build(BuildContext context) {
    return Scaffold(
      //// Handle Perubahan State dari MQTT
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
          Switch(
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
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        height: double.infinity,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //// Handle Ubah Nama
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 125,
                    child: Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5, child: Text(":")),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.device.name,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                              Icons.drive_file_rename_outline_rounded),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: "Edit Name",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 125,
                      child: Text(
                        "Device ID",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5, child: Text(":")),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        widget.device.deviceId,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 125,
                      child: Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5, child: Text(":")),
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
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 125,
                      child: Text(
                        "Signal strength",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5, child: Text(":")),
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
                    width: 125,
                    child: Text(
                      "Role",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5, child: Text(":")),
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
              //// Handle Ubah Nama
              Row(
                children: [
                  const SizedBox(
                    width: 125,
                    child: Text(
                      "Mesh name",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5, child: Text(":")),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.device.meshNetwork.name,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                              Icons.drive_file_rename_outline_rounded),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: "Edit Name",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 125,
                      child: Text(
                        "Mesh Address",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5, child: Text(":")),
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
              //// Handle MQTT Timer State (Belum buat di Kodingan alatnya!!)
              //// Buat database juga untuk menyimpan data alarm pada setiap device
              //// Buat alarm mana yang bisa digunakan (ada tombol switchnya di database) biar nanti tinggal apply
              Material(
                color: ColorConstants.whiteAppColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _openTimeThenStatePicker(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 64,
                    child: Center(
                      child: Text(
                        "Set Timer",
                        style: TextStyle(
                          color: ColorConstants.darkBlueAppColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTimeThenStatePicker(BuildContext context) {
    BottomPicker.time(
      pickerTitle: Text(
        'Set your Device State timer',
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
        print('Time picked hour: ${jam.hour}');
        print('Time picked minute: ${jam.minute}');
        // Setelah selesai, buka picker berikutnya
        Future.delayed(const Duration(milliseconds: 300), () {
          _openDeviceStatePicker(context);
        });
      },
      onCloseButtonPressed: () {
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
      selectedItemIndex: 1,
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
        print('Selected: ${index == 0 ? 'OFF' : 'ON'}');
      },
      onCloseButtonPressed: () {
        print('Device state picker closed');
      },
    ).show(context);
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }
}
