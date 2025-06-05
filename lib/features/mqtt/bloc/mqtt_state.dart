part of 'mqtt_bloc.dart';

abstract class MQTTState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MQTTInitial extends MQTTState {}

class MQTTConnecting extends MQTTState {}

class MQTTError extends MQTTState {
  final String message;

  MQTTError(this.message);

  @override
  List<Object?> get props => [message];
}

class MQTTConnected extends MQTTState {
  final List<DeviceStatuses> deviceStatuses;
  final List<MeshMessage> meshMessages;

  MQTTConnected({
    this.deviceStatuses = const [],
    this.meshMessages = const [],
  });

  MQTTConnected copyWith({
    List<DeviceStatuses>? deviceStatuses,
    List<MeshMessage>? meshMessages,
  }) {
    return MQTTConnected(
      deviceStatuses: deviceStatuses ?? this.deviceStatuses,
      meshMessages: meshMessages ?? this.meshMessages,
    );
  }

  @override
  List<Object?> get props => [deviceStatuses, meshMessages];
}

class MQTTDisconnected extends MQTTState {
  final String reason;

  MQTTDisconnected(this.reason);

  @override
  List<Object?> get props => [reason];
}
