part of 'device_schedule_bloc.dart';

abstract class DeviceScheduleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetDeviceSchedulesByDeviceId extends DeviceScheduleEvent {
  final int deviceId;

  GetDeviceSchedulesByDeviceId({required this.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

class InsertDeviceSchedulewithDeviceId extends DeviceScheduleEvent {
  final int deviceId;
  final String time;
  final String state;
  final bool enabled;

  InsertDeviceSchedulewithDeviceId({
    required this.deviceId,
    required this.time,
    required this.state,
    required this.enabled,
  });

  @override
  List<Object?> get props => [
        deviceId,
        time,
        state,
        enabled,
      ];
}

class UpdateDeviceScheduleEnabled extends DeviceScheduleEvent {
  final int scheduleId;
  final bool enabled;

  UpdateDeviceScheduleEnabled({
    required this.scheduleId,
    required this.enabled,
  });

  @override
  List<Object?> get props => [scheduleId, enabled];
}

class DeleteDeviceSchedule extends DeviceScheduleEvent {
  final int scheduleId;

  DeleteDeviceSchedule({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}
