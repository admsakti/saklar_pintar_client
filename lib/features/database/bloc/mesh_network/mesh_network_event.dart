part of 'mesh_network_bloc.dart';

abstract class MeshNetworkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsertMeshNetwork extends MeshNetworkEvent {
  final String macRoot;
  final String meshName;

  InsertMeshNetwork({
    required this.macRoot,
    required this.meshName,
  });

  @override
  List<Object?> get props => [
        macRoot,
        meshName,
      ];
}

class GetMeshNetworks extends MeshNetworkEvent {}

class GetMeshNetwork extends MeshNetworkEvent {
  final String macRoot;

  GetMeshNetwork({required this.macRoot});

  @override
  List<Object?> get props => [macRoot];
}

class UpdateMeshNetwork extends MeshNetworkEvent {
  final int id;
  final String? macRoot;
  final String? name;

  UpdateMeshNetwork({
    required this.id,
    this.macRoot,
    this.name,
  });

  @override
  List<Object?> get props => [
        id,
        macRoot,
        name,
      ];
}

class DeleteMeshNetworks extends MeshNetworkEvent {}

class DeleteMeshNetwork extends MeshNetworkEvent {
  final int id;

  DeleteMeshNetwork({required this.id});

  @override
  List<Object?> get props => [id];
}
