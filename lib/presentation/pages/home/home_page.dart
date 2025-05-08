import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saklar_pintar_client/features/database/bloc/mesh_network/mesh_network_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';
import '../../widgets/node_toggle/node_toggle_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MQTTBloc>().add(ConnectMQTT());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final data = parseNodeData(msg.value);

                return NodeToggleWidget(
                  roomName: getRoomName(msg.nodeId),
                  isOnline: (data['status'] ?? '').toLowerCase() == 'online',
                  indicatorColor:
                      (data['status'] ?? '').toLowerCase() == 'online'
                          ? Colors.green
                          : Colors.red,
                  onTap: () {
                    final isCurrentlyOnline =
                        (data['status'] ?? '').toLowerCase() == 'online';
                    final newCommand = isCurrentlyOnline ? 'off' : 'on';

                    context.read<MQTTBloc>().add(
                          PublishMessage(
                            'mesh/control/${msg.nodeId}',
                            newCommand,
                          ),
                        );
                  },
                );
              },
            );
          } else if (state is MQTTError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('No Device Available'));
        },
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

  String getRoomName(String nodeId) {
    final map = {
      'node1': 'Ruang Tamu',
      'node2': 'Kamar Mandi',
      'node3': 'Teras',
      'node4': 'Kamar Depan',
      'node5': 'Dapur',
      'node6': 'Kamar Belakang',
    };
    return map[nodeId] ?? nodeId;
  }

  void _onDeviceProvisioningTapped(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/DeviceProvisioning',
      arguments: context,
    );
  }
}
