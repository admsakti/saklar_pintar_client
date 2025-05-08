import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/mesh_network/mesh_network_bloc.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';
import '../../widgets/device_toggle/device_toggle_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MeshNetworkBloc>().add(GetMeshNetworks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MQTTBloc, MQTTState>(
      listener: (context, state) {
        if (state is MQTTConnected) {
          context.read<MQTTBloc>().add(SubscribedMeshNetwork());
          context.read<MQTTBloc>().add(DeviceReceivedMessage());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.lightBlueAppColor,
          title: BlocBuilder<MeshNetworkBloc, MeshNetworkState>(
            builder: (context, state) {
              if (state is MeshNetworksLoaded) {
                return Text('Mesh-Net App ${state.meshNetworks.length}');
              }
              return const Text('Mesh-Net App');
            },
          ),
          actions: [
            IconButton(
              onPressed: () => _onDeviceProvisioningTapped(context),
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: "Add Device",
            ),
          ],
        ),
        body: BlocBuilder<MQTTBloc, MQTTState>(
          builder: (context, state) {
            if (state is MQTTConnecting) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MQTTConnected) {
              final messages = state.messages;
              // filter Device lagi karena device yang sama malah bisa buat widget (1 device 1 widget aja, jika sama update sebelumnya)

              print("MQTT Device Statuses: $messages");

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final data = parseNodeData(msg.value);

                  return DeviceToggleWidget(
                    deviceName: msg.nodeId,
                    isOnline: (data['status'] ?? '') == 'ON',
                    meshName: "coba",
                    signalStrength: "-50dBm",
                    indicatorColor: (data['status'] ?? '') == 'ON'
                        ? Colors.green
                        : Colors.red,
                    onTap: () {
                      final isCurrentlyOnline = (data['status'] ?? '') == 'ON';
                      final newCommand = isCurrentlyOnline ? 'OFF' : 'ON';
                      // masih error Published to painlessMesh/gateway/controls/0123456789/set: OFF hanya kirim off karena isCurrentlyOnline nilai true

                      context.read<MQTTBloc>().add(
                            SetDeviceState(
                              deviceId: msg.nodeId,
                              value: newCommand,
                            ),
                          );
                    },
                  );
                },
              );
            } else if (state is MQTTError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            // jika tidak tersambung ke MQTT atau tidak memiliki data device di sqflite
            return const Center(child: Text('No Device Available'));
          },
        ),
      ),
    );
  }

  Map<String, dynamic> parseNodeData(String value) {
    try {
      return json.decode(value);
    } catch (_) {
      return {};
    }
  }

  void _onDeviceProvisioningTapped(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/DeviceProvisioning',
      arguments: context,
    );
  }
}
