part of 'device_schedule_bloc.dart';

abstract class DeviceScheduleState {}

class DeviceScheduleInitial extends DeviceScheduleState {}

class DeviceScheduleLoading extends DeviceScheduleState {}

class DeviceScheduleFailure extends DeviceScheduleState {
  final String message;

  DeviceScheduleFailure(this.message);
}

class SaveDeviceScheduleSuccess extends DeviceScheduleState {}

class DeviceScheduleLoaded extends DeviceScheduleState {
  final List<DeviceSchedule> schedules;

  DeviceScheduleLoaded(this.schedules);
}

class UpdateDeviceScheduleSuccess extends DeviceScheduleState {}

class DeleteDeviceScheduleSuccess extends DeviceScheduleState {}
