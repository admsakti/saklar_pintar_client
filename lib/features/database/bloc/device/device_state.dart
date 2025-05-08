part of 'device_bloc.dart';

abstract class DeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceFailure extends DeviceState {
  final String message;

  DeviceFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SaveDeviceSuccess extends DeviceState {}

class DevicesLoaded extends DeviceState {
  final List<Device> devices;

  DevicesLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceLoaded extends DeviceState {
  final Device device;

  DeviceLoaded(this.device);

  @override
  List<Object?> get props => [device];
}

class UpdateDeviceSuccess extends DeviceState {}

class DeleteDevicesSuccess extends DeviceState {}

class DeleteDeviceSuccess extends DeviceState {}
