part of 'device_bloc.dart';

abstract class DeviceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsertDeviceWithMacRoot extends DeviceEvent {
  final String macRoot;
  final String nodeId;
  final String name;
  final String role;

  InsertDeviceWithMacRoot({
    required this.macRoot,
    required this.nodeId,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [
        macRoot,
        nodeId,
        name,
        role,
      ];
}

class GetDevices extends DeviceEvent {}

class GetDeviceById extends DeviceEvent {
  final int id;

  GetDeviceById({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateDeviceName extends DeviceEvent {
  final int id;
  final String? name;

  UpdateDeviceName({
    required this.id,
    this.name,
  });

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}

class DeleteDevices extends DeviceEvent {}

class DeleteDeviceById extends DeviceEvent {
  final int id;

  DeleteDeviceById({required this.id});

  @override
  List<Object?> get props => [id];
}
