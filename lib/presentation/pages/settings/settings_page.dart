import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/arguments/devices_arguments.dart';
import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';
import '../../../features/database/bloc/mesh_network/mesh_network_bloc.dart';
import '../../../features/database/models/device.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        title: const Text('Settings'),
        actions: [
          BlocBuilder<MQTTBloc, MQTTState>(
            builder: (context, state) {
              Color indicatorColor;
              // Dart versi 3 memperkenalkan pattern matching
              switch (state) {
                case MQTTConnecting _:
                  indicatorColor = Colors.orange;
                  break;
                case MQTTConnected _:
                  indicatorColor = Colors.green;
                  break;
                case MQTTDisconnected _:
                  indicatorColor = Colors.red;
                  break;
                default:
                  indicatorColor = Colors.grey;
              }

              return Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor,
                  boxShadow: [
                    BoxShadow(
                      color: indicatorColor.withOpacity(0.6),
                      spreadRadius: 2,
                      blurRadius: 6,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: BlocListener<MeshNetworkBloc, MeshNetworkState>(
        listener: (context, state) {
          if (state is MeshNetworkLoading) {
            const Center(child: CircularProgressIndicator());
          } else if (state is DeleteAllMeshDeviceRelationsSuccess) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return PopScope(
                  canPop: false,
                  child: AlertDialog(
                    backgroundColor: ColorConstants.lightBlueAppColor,
                    title: const Text('All Devices are already removed!'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Semua Device dan Mesh network berhasil di hapus'),
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
          } else if (state is MeshNetworkFailure) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return PopScope(
                  canPop: false,
                  child: AlertDialog(
                    backgroundColor: ColorConstants.lightBlueAppColor,
                    title: const Text('Error remove all Devices!'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const Text(
                            'Gagal menghapus semua device dan mesh network yang terhubung dengan client'),
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
          Container();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox.fromSize(size: const Size.fromHeight(25)),
                BlocBuilder<DeviceBloc, DeviceState>(
                  builder: (context, state) {
                    final isDevicesLoaded = state is DevicesLoaded;
                    final devices =
                        state is DevicesLoaded ? state.devices : <Device>[];
                    return Column(
                      children: [
                        Material(
                          color: isDevicesLoaded && devices.isNotEmpty
                              ? ColorConstants.whiteAppColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: isDevicesLoaded && devices.isNotEmpty
                                ? () => _onViewDevicesTapped(context, devices)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              height: 64,
                              child: Center(
                                child: Text(
                                  "View All Devices",
                                  style: TextStyle(
                                    color: isDevicesLoaded && devices.isNotEmpty
                                        ? ColorConstants.darkBlueAppColor
                                        : Colors.black54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox.fromSize(size: const Size.fromHeight(25)),
                        Material(
                          color: isDevicesLoaded && devices.isNotEmpty
                              ? ColorConstants.whiteAppColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: isDevicesLoaded && devices.isNotEmpty
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor:
                                            ColorConstants.lightBlueAppColor,
                                        title: const Text(
                                          "Delete All Devices",
                                        ),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                "Yakin ingin menghapus semua Device?"),
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
                                            onPressed: () =>
                                                _onDeleteAllMeshDeviceRelations(
                                                    context),
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
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              height: 64,
                              child: Center(
                                child: Text(
                                  "Delete All Devices",
                                  style: TextStyle(
                                    color: isDevicesLoaded && devices.isNotEmpty
                                        ? ColorConstants.darkBlueAppColor
                                        : Colors.black54,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 180, bottom: 45),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'lib/assets/images/banner_putih_biru.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 95,
                        child: Text(
                          "Developer",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5, child: Text(":")),
                      SizedBox(
                        width: 200,
                        child: GestureDetector(
                          onLongPress: () =>
                              _onDeveloperModeLongPressed(context),
                          child: const Text(
                            "Sakti Bayu Nugraha",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
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
    );
  }

  void _onViewDevicesTapped(BuildContext context, List<Device> devices) {
    Navigator.pushNamed(
      context,
      '/ViewDevicesChart',
      arguments: DevicesArguments(context, devices),
    );
  }

  void _onDeveloperModeLongPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/DeveloperMode',
      arguments: context,
    );
  }

  _onDeleteAllMeshDeviceRelations(BuildContext context) async {
    context.read<MeshNetworkBloc>().add(
          DeleteAllMeshDeviceRelations(),
        );
  }
}
