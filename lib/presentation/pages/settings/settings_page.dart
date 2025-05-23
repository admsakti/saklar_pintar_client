import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        title: const Text('Settings'),
      ),
      body: BlocListener<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceLoading) {
            const Center(child: CircularProgressIndicator());
          } else if (state is DeleteAllDevicesAndMeshNetworksSuccess) {
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
          } else if (state is DeviceFailure) {
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
                Material(
                  color: ColorConstants.whiteAppColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap:
                        () {}, // bagaimana cara menampilkan list devicennya??
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 64,
                      child: Center(
                        child: Text(
                          "View All Devices",
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
                SizedBox.fromSize(size: const Size.fromHeight(25)),
                Material(
                  color: ColorConstants.whiteAppColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: ColorConstants.lightBlueAppColor,
                          title: const Text(
                            "Delete All Devices",
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Yakin ingin menghapus semua Device?"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.green,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Tidak',
                                style: TextStyle(
                                  color: ColorConstants.blackAppColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.red,
                                ),
                              ),
                              onPressed: () =>
                                  _onDeleteAllDevicesAndMeshNetworks(context),
                              child: Text(
                                'Ya!',
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
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 64,
                      child: Center(
                        child: Text(
                          "Delete All Devices",
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
                const Padding(
                  padding: EdgeInsets.only(top: 200, bottom: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 95,
                        child: Text(
                          "Version",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 5, child: Text(":")),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "0.0.1",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 95,
                        child: Text(
                          "Developer",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 5, child: Text(":")),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "Sakti Bayu Nugraha",
                          style: TextStyle(
                            fontSize: 16,
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

  _onDeleteAllDevicesAndMeshNetworks(BuildContext context) async {
    context.read<DeviceBloc>().add(
          DeleteAllDevicesAndMeshNetworks(),
        );
  }
}
