part of 'device_bloc.dart';

abstract class DeviceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsertDeviceWithMacRoot extends DeviceEvent {
  final String macRoot;
  final String deviceId;
  final String name;
  final String role;

  InsertDeviceWithMacRoot({
    required this.macRoot,
    required this.deviceId,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [
        macRoot,
        deviceId,
        name,
        role,
      ];
}

class InsertDevice extends DeviceEvent {
  final String deviceId;
  final String name;
  final String role;
  final int meshId;

  InsertDevice({
    required this.deviceId,
    required this.name,
    required this.role,
    required this.meshId,
  });

  @override
  List<Object?> get props => [
        deviceId,
        name,
        role,
        meshId,
      ];
}

class GetDevices extends DeviceEvent {}

class GetDevice extends DeviceEvent {
  final int id;

  GetDevice({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateDevice extends DeviceEvent {
  final int id;
  final String? deviceId;
  final String? name;
  final String? role;
  final int? meshId;

  UpdateDevice({
    required this.id,
    this.deviceId,
    this.name,
    this.role,
    this.meshId,
  });

  @override
  List<Object?> get props => [
        id,
        deviceId,
        name,
        role,
        meshId,
      ];
}

class DeleteDevices extends DeviceEvent {}

class DeleteDevice extends DeviceEvent {
  final int id;

  DeleteDevice({required this.id});

  @override
  List<Object?> get props => [id];
}
