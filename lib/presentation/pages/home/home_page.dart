import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';
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
    context.read<DeviceBloc>().add(GetDevices());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MQTTBloc, MQTTState>(
      // BlocListener seharusnya bukan di sini!!!
      listenWhen: (previous, current) =>
          current is MQTTConnected && previous is! MQTTConnected,
      listener: (context, state) {
        if (state is MQTTConnected) {
          context.read<MQTTBloc>().add(SubscribedMeshNetwork());
          // context.read<DeviceBloc>().add(GetDevices());
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
        body: CustomRefreshIndicator(
          onRefresh: () async {
            context.read<MQTTBloc>().add(
                  RequestDevicesData(command: 'getNodes'),
                );
            // context.read<DeviceBloc>().add(GetDevices());
            await Future.delayed(
              const Duration(seconds: 2),
            );
          },
          builder: (BuildContext context, Widget child,
              IndicatorController controller) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (controller.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                          value: controller.state.isLoading
                              ? null
                              : math.min(controller.value, 1.0),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: controller.value * 60),
                      child: child,
                    ),
                  ],
                );
              },
            );
          },
          child: BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state is DeviceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DevicesLoaded) {
                final devices = state.devices;
                // filter Device lagi karena device yang sama malah bisa buat widget (1 device 1 widget aja, jika sama update sebelumnya)

                print("Devices for MQTT: $devices");

                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return DeviceToggleWidget(
                      key: ValueKey(devices[index].id), // ID unik dari device
                      device: devices[index],
                    );
                  },
                );
              } else if (state is DeviceFailure) {
                return Center(child: Text('Error: ${state.message}'));
              }
              // jika tidak tersambung ke MQTT atau tidak memiliki data device di sqflite
              return const Center(child: Text('No Device Available'));
            },
          ),
        ),
      ),
    );
  }

  void _onDeviceProvisioningTapped(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/DeviceProvisioning',
      arguments: context,
    );
  }
}
