import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/database_helper.dart';
import '../../models/mesh_network.dart';

part 'mesh_network_event.dart';
part 'mesh_network_state.dart';

class MeshNetworkBloc extends Bloc<MeshNetworkEvent, MeshNetworkState> {
  final DatabaseHelper _database;

  MeshNetworkBloc(this._database) : super(MeshNetworkInitial()) {
    on<InsertMeshNetwork>(onInsertMeshNetwork);
    on<GetMeshNetworks>(onGetMeshNetworks);
    on<GetMeshNetwork>(onGetMeshNetwork);
    on<UpdateMeshNetwork>(onUpdateMeshNetwork);
    on<DeleteMeshNetworks>(onDeleteMeshNetworks);
    on<DeleteMeshNetwork>(onDeleteMeshNetwork);
  }

  Future<void> onInsertMeshNetwork(
    InsertMeshNetwork event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());

    try {
      await _database.insertMeshNetwork(
        meshNetwork: MeshNetwork(
          macRoot: event.macRoot,
          name: event.meshName,
        ),
      );

      emit(SaveMeshNetworkSuccess());
    } catch (e) {
      emit(MeshNetworkFailure('Gagal menyimpan Mesh Metwork: $e'));
    }
  }

  Future<void> onGetMeshNetworks(
    GetMeshNetworks event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());
    try {
      final meshNetworks = await _database.getMeshNetworks();
      emit(MeshNetworksLoaded(meshNetworks));
    } catch (e) {
      emit(MeshNetworkFailure('Failed to load Mesh Networks: $e'));
    }
  }

  Future<void> onGetMeshNetwork(
    GetMeshNetwork event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());
    try {
      final meshNetwork = await _database.getMeshNetwork(id: event.id);

      if (meshNetwork == null) {
        emit(MeshNetworkFailure('Mesh dengan MAC ${event.id} tidak ditemukan'));
        return;
      }

      emit(MeshNetworkLoaded(meshNetwork));
    } catch (e) {
      emit(MeshNetworkFailure('Failed to load Mesh Network: $e'));
    }
  }

  Future<void> onGetMeshNetworkByMacRoot(
    GetMeshNetworkByMacRoot event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());
    try {
      final meshNetwork =
          await _database.getMeshNetworkByMacRoot(macRoot: event.macRoot);

      if (meshNetwork == null) {
        emit(MeshNetworkFailure(
            'Mesh dengan MAC ${event.macRoot} tidak ditemukan'));
        return;
      }

      emit(MeshNetworkLoaded(meshNetwork));
    } catch (e) {
      emit(MeshNetworkFailure('Failed to load Mesh Network: $e'));
    }
  }

  Future<void> onUpdateMeshNetwork(
    UpdateMeshNetwork event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());
    try {
      await _database.updateMeshNetwork(
        id: event.id,
        name: event.name,
        macRoot: event.macRoot,
      );
      emit(UpdateMeshNetworkSuccess());
    } catch (e) {
      emit(MeshNetworkFailure('Failed to update Mesh Network: $e'));
    }
  }

  Future<void> onDeleteMeshNetworks(
    DeleteMeshNetworks event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());
    try {
      await _database.resetMeshNetworkTable();
      emit(DeleteMeshNetworksSuccess());
    } catch (e) {
      emit(MeshNetworkFailure('Failed to delete Mesh Networks: $e'));
    }
  }

  Future<void> onDeleteMeshNetwork(
    DeleteMeshNetwork event,
    Emitter<MeshNetworkState> emit,
  ) async {
    emit(MeshNetworkLoading());
    try {
      await _database.deleteMeshNetwork(id: event.id);
      emit(DeleteMeshNetworkSuccess());
    } catch (e) {
      emit(MeshNetworkFailure('Failed to delete Mesh Network: $e'));
    }
  }
}
