part of 'mesh_network_bloc.dart';

abstract class MeshNetworkState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MeshNetworkInitial extends MeshNetworkState {}

class MeshNetworkLoading extends MeshNetworkState {}

class MeshNetworkFailure extends MeshNetworkState {
  final String message;

  MeshNetworkFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SaveMeshNetworkSuccess extends MeshNetworkState {}

class MeshNetworksLoaded extends MeshNetworkState {
  final List<MeshNetwork> meshNetworks;

  MeshNetworksLoaded(this.meshNetworks);

  @override
  List<Object?> get props => [meshNetworks];
}

class MeshNetworkLoaded extends MeshNetworkState {
  final MeshNetwork meshNetwork;

  MeshNetworkLoaded(this.meshNetwork);

  @override
  List<Object?> get props => [meshNetwork];
}

class UpdateMeshNetworkSuccess extends MeshNetworkState {}

class DeleteMeshNetworksSuccess extends MeshNetworkState {}

class DeleteMeshNetworkSuccess extends MeshNetworkState {}
