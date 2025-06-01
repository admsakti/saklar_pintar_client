import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/database_helper.dart';
import '../../models/device_schedule.dart';

part 'device_schedule_event.dart';
part 'device_schedule_state.dart';

class DeviceScheduleBloc
    extends Bloc<DeviceScheduleEvent, DeviceScheduleState> {
  final DatabaseHelper _database;

  DeviceScheduleBloc(this._database) : super(DeviceScheduleInitial()) {
    on<GetDeviceSchedulesByDeviceId>(_onGetDeviceSchedulesByDeviceId);
    on<InsertDeviceSchedulewithDeviceId>(_onInsertDeviceSchedulewithDeviceId);
    on<UpdateDeviceScheduleEnabled>(_onUpdateDeviceScheduleEnabled);
    on<DeleteDeviceSchedule>(_onDeleteDeviceSchedule);
  }

  Future<void> _onGetDeviceSchedulesByDeviceId(
    GetDeviceSchedulesByDeviceId event,
    Emitter<DeviceScheduleState> emit,
  ) async {
    emit(DeviceScheduleLoading());
    try {
      final result = await _database.getSchedulesByDeviceId(
        deviceId: event.deviceId,
      );
      emit(DeviceScheduleLoaded(result));
    } catch (e) {
      emit(DeviceScheduleFailure('Failed to load schedules'));
    }
  }

  Future<void> _onInsertDeviceSchedulewithDeviceId(
    InsertDeviceSchedulewithDeviceId event,
    Emitter<DeviceScheduleState> emit,
  ) async {
    emit(DeviceScheduleLoading());
    try {
      await _database.insertDeviceSchedulewithDeviceId(
        deviceId: event.deviceId,
        time: event.time,
        state: event.state,
        enabled: event.enabled,
      );
      emit(SaveDeviceScheduleSuccess());

      add(GetDeviceSchedulesByDeviceId(deviceId: event.deviceId));
    } catch (e) {
      emit(DeviceScheduleFailure('Failed to add schedule'));
    }
  }

  Future<void> _onUpdateDeviceScheduleEnabled(
    UpdateDeviceScheduleEnabled event,
    Emitter<DeviceScheduleState> emit,
  ) async {
    emit(DeviceScheduleLoading());
    try {
      await _database.updateDeviceScheduleEnabled(
        scheduleId: event.scheduleId,
        enabled: event.enabled,
      );
      emit(UpdateDeviceScheduleSuccess());
    } catch (e) {
      emit(DeviceScheduleFailure('Failed to update schedule'));
    }
  }

  Future<void> _onDeleteDeviceSchedule(
    DeleteDeviceSchedule event,
    Emitter<DeviceScheduleState> emit,
  ) async {
    emit(DeviceScheduleLoading());
    try {
      await _database.deleteDeviceSchedule(
        scheduleId: event.scheduleId,
      );
      emit(DeleteDeviceScheduleSuccess());
    } catch (e) {
      emit(DeviceScheduleFailure('Failed to delete schedule'));
    }
  }
}
