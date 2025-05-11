import 'package:equatable/equatable.dart';

import 'mesh_network.dart';

class Device extends Equatable {
  final int? id;
  final String deviceId;
  final String name;
  final String role; // root / node
  final MeshNetwork meshNetwork; // Data Model Mesh Network

  const Device({
    this.id,
    required this.deviceId,
    required this.name,
    required this.role,
    required this.meshNetwork,
  });

  @override
  List<Object?> get props => [
        id,
        deviceId,
        name,
        role,
        meshNetwork,
      ];

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'deviceId': deviceId,
  //     'name': name,
  //     'role': role,
  //     'meshNetwork': meshNetwork,
  //   };
  // }

  factory Device.fromMapWithMeshNetwork(Map<String, dynamic> map) {
    return Device(
      id: map['idDevice'],
      deviceId: map['deviceIdentifier'],
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
