import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/database_helper.dart';
import '../../models/device.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DatabaseHelper _database;

  DeviceBloc(this._database) : super(DeviceInitial()) {
    on<InsertDeviceWithMacRoot>(onInsertDeviceWithMacRoot);
    // on<InsertDevice>(onInsertDevice); // Sepertinya tidak dipakai
    on<GetDevices>(onGetDevices);
    on<GetDeviceById>(onGetDeviceById);
    on<UpdateDeviceName>(onUpdateDeviceName);
    on<DeleteDevices>(onDeleteDevices);
    on<DeleteDeviceById>(onDeleteDeviceById);
  }

  Future<void> onInsertDeviceWithMacRoot(
    InsertDeviceWithMacRoot event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    try {
      final meshNetwork =
          await _database.getMeshNetworkByMacRoot(macRoot: event.macRoot);

      if (meshNetwork == null) {
        emit(DeviceFailure('Mesh dengan MAC ${event.macRoot} tidak ditemukan'));
        return;
      }

      await _database.insertDeviceWithMacRoot(
        macRoot: event.macRoot,
        deviceId: event.deviceId,
        name: event.name,
        role: event.role,
      );

      emit(SaveDeviceSuccess());
    } catch (e) {
      emit(DeviceFailure('Gagal menyimpan device: $e'));
    }
  }

  // Future<void> onInsertDevice(
  //   InsertDevice event,
  //   Emitter<DeviceState> emit,
  // ) async {
  //   try {
  //     await _database.insertDevice(
  //       device: Device(
  //         deviceId: event.deviceId,
  //         name: event.name,
  //         role: event.role,
  //         meshId: event.meshId,
  //       ),
  //     );
  //     // add(GetDevices()); // refresh after insert
  //     emit(SaveDeviceSuccess());
  //   } catch (e) {
  //     emit(DeviceFailure('Gagal menyimpan device: $e'));
  //   }
  // }

  Future<void> onGetDevices(
    GetDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      final devices = await _database.getDevices();
      emit(DevicesLoaded(devices));
    } catch (e) {
      emit(DeviceFailure('Failed to load devices'));
    }
  }

  Future<void> onGetDeviceById(
    GetDeviceById event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      final device = await _database.getDeviceById(id: event.id);

      if (device == null) {
        emit(DeviceFailure('Device dengan id ${event.id} tidak ditemukan'));
        return;
      }

      emit(DeviceLoaded(device));
    } catch (e) {
      emit(DeviceFailure('Failed to load Device: $e'));
    }
  }

  Future<void> onUpdateDeviceName(
    UpdateDeviceName event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      await _database.updateDeviceName(
        id: event.id,
        name: event.name,
      );
      emit(UpdateDeviceSuccess());
    } catch (e) {
      emit(DeviceFailure('Failed to update Device: $e'));
    }
  }

  Future<void> onDeleteDevices(
    DeleteDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      await _database.resetDeviceTable();
      emit(DeleteDevicesSuccess());
    } catch (e) {
      emit(DeviceFailure('Failed to delete Devices: $e'));
    }
  }

  Future<void> onDeleteDeviceById(
    DeleteDeviceById event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      await _database.deleteDeviceById(id: event.id);
      emit(DeleteDeviceSuccess());
    } catch (e) {
      emit(DeviceFailure('Failed to delete Device: $e'));
    }
  }
}
