import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
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
              Material(
                color: ColorConstants.whiteAppColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  // onTap: _isFormValid ? () => _startProvisioning() : null,
                  onTap: () => _onDeleteMeshNetworks(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 64,
                    child: Center(
                      child: Text(
                        "Delete Mesh Networks",
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

  _onDeleteMeshNetworks(BuildContext context) async {
    context.read<MeshNetworkBloc>().add(
          DeleteMeshNetworks(),
        );
  }
}
