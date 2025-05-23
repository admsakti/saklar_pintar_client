import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';
import '../../../features/database/bloc/mesh_network/mesh_network_bloc.dart';
import '../../../features/database/models/mesh_network.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';
import '../../widgets/device_toggle/device_toggle_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<CustomRefreshIndicatorState> _refreshKey =
      GlobalKey<CustomRefreshIndicatorState>();
  List<MeshNetwork>? cachedMeshNetworksForSubscribe;
  List<MeshNetwork>? cachedMeshNetworksForRequest;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MeshNetworkBloc, MeshNetworkState>(
          listener: (context, state) {
            if (state is MeshNetworksLoaded) {
              print("Home MeshNetworksLoaded: ${state.meshNetworks}");

              setState(() {
                cachedMeshNetworksForSubscribe = state.meshNetworks;
                cachedMeshNetworksForRequest = state.meshNetworks;
              });
            }
          },
        ),
        BlocListener<MQTTBloc, MQTTState>(
          listener: (context, state) {
            if (state is MQTTConnected &&
                cachedMeshNetworksForSubscribe != null) {
              for (var mesh in cachedMeshNetworksForSubscribe!) {
                print("Home SubscribedMeshNetwork: ${mesh.id}/${mesh.macRoot}");

                context
                    .read<MQTTBloc>()
                    .add(SubscribedMeshNetwork(macRoot: mesh.macRoot));
              }

              setState(() {
                // Kosongkan cache agar tidak kirim ulang
                cachedMeshNetworksForSubscribe = null;
              });
            }
          },
        ),
      ],
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
            // Refresh manual dengan tombol
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                _refreshKey.currentState?.refresh(
                  draggingCurve: Curves.easeOutBack,
                );
              },
              tooltip: "Refresh Devices",
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => _onDeviceProvisioningTapped(context),
              tooltip: "Add Device",
            ),
          ],
        ),
        body: CustomRefreshIndicator(
          key: _refreshKey,
          onRefresh: () async {
            context.read<DeviceBloc>().add(GetDevices());

            if (cachedMeshNetworksForRequest != null) {
              for (var mesh in cachedMeshNetworksForRequest!) {
                print("Home RequestDevicesData: ${mesh.id}/${mesh.macRoot}");

                context.read<MQTTBloc>().add(
                      RequestDevicesData(
                        macRoot: mesh.macRoot,
                        command: 'getNodes',
                      ),
                    );
              }
            }
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
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                            value: controller.state.isLoading
                                ? null
                                : math.min(controller.value, 1.0),
                          ),
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

                print("Home Devices: $devices");

                if (devices.isNotEmpty) {
                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return DeviceToggleWidget(
                        key: ValueKey(devices[index].id), // ID unik dari device
                        device: devices[index],
                      );
                    },
                  );
                }

                return SingleChildScrollView(
                  // agar bisa pull-down meski tidak ada konten
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'No Device Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox.fromSize(size: const Size.fromHeight(20)),
                        Material(
                          color: ColorConstants.whiteAppColor,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => _onDeviceProvisioningTapped(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.transparent,
                              width: 240,
                              height: 48,
                              child: Center(
                                child: Text(
                                  "Add Mesh-Net Device",
                                  style: TextStyle(
                                    color: ColorConstants.darkBlueAppColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is DeviceFailure) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        'Error loading devices. Error: ${state.message}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'No Device Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox.fromSize(size: const Size.fromHeight(20)),
                      Material(
                        color: ColorConstants.whiteAppColor,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _onDeviceProvisioningTapped(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: Colors.transparent,
                            width: 240,
                            height: 48,
                            child: Center(
                              child: Text(
                                "Add Mesh-Net Device",
                                style: TextStyle(
                                  color: ColorConstants.darkBlueAppColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
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
