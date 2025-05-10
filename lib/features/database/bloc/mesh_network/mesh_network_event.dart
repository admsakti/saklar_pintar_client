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

class GetMeshNetworkByMacRoot extends MeshNetworkEvent {
  final String macRoot;

  GetMeshNetworkByMacRoot({required this.macRoot});

  @override
  List<Object?> get props => [macRoot];
}

class GetMeshNetworkById extends MeshNetworkEvent {
  final int id;

  GetMeshNetworkById({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateMeshNetworkName extends MeshNetworkEvent {
  final int id;
  final String? name;

  UpdateMeshNetworkName({
    required this.id,
    this.name,
  });

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}

class DeleteMeshNetworks extends MeshNetworkEvent {}

class DeleteMeshNetworkById extends MeshNetworkEvent {
  final int id;

  DeleteMeshNetworkById({required this.id});

  @override
  List<Object?> get props => [id];
}
