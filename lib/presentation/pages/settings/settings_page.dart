import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';
import '../../../features/database/bloc/mesh_network/mesh_network_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox.fromSize(size: const Size.fromHeight(25)),
              //// Handle State Bloc Device dan Mesh Network
              Material(
                color: ColorConstants.whiteAppColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _onDeleteMeshNetworks(context),
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
              SizedBox.fromSize(size: const Size.fromHeight(25)),
              Material(
                color: ColorConstants.whiteAppColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {},
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
    );
  }

  _onDeleteMeshNetworks(BuildContext context) async {
    context.read<DeviceBloc>().add(
          DeleteDevices(),
        );
    context.read<MeshNetworkBloc>().add(
          DeleteMeshNetworks(),
        );
  }
}
