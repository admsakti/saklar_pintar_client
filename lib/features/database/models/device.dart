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

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'nodeId': nodeId,
  //     'name': name,
  //     'role': role,
  //     'meshNetwork': meshNetwork,
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
