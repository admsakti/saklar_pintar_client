import 'package:equatable/equatable.dart';

import 'mesh_network.dart';

class Device extends Equatable {
  final int? id;
  final String nodeId;
  final String name;
  final String role; // root / node
  final MeshNetwork meshNetwork; // Data Model Mesh Network

  const Device({
    this.id,
    required this.nodeId,
    required this.name,
    required this.role,
    required this.meshNetwork,
  });

  @override
  List<Object?> get props => [
        id,
        nodeId,
        name,
        role,
        meshNetwork,
      ];

  // Map<String, dynamic> toMapWithMeshNetwork() {
  //   return {
  //     'idDevice': id,
  //     'nodeId': nodeId,
  //     'deviceName': name,
  //     'deviceRole': role,
  //     "idMesh": meshNetwork.id,
  //     "macRoot": meshNetwork.macRoot,
  //     "meshName": meshNetwork.name,
  //   };
  // }

  factory Device.fromMapWithMeshNetwork(Map<String, dynamic> map) {
    return Device(
      id: map['idDevice'],
      nodeId: map['deviceIdentifier'],
      name: map['name'],
      role: map['role'],
      meshNetwork: MeshNetwork(
        id: map['idMesh'],
        macRoot: map['macIdentifier'],
        name: map['meshName'],
      ),
    );
  }
}
