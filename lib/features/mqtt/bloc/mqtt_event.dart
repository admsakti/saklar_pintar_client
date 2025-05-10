part of 'mqtt_bloc.dart';

abstract class MQTTEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectMQTT extends MQTTEvent {}

class MessageReceived extends MQTTEvent {
  final DeviceStatuses? deviceStatuses;
  final MeshMessage? meshMessage;

  MessageReceived({
    this.deviceStatuses,
    this.meshMessage,
  }) : assert(deviceStatuses != null || meshMessage != null,
            'Either deviceStatuses or meshMessage must be provided.');

  @override
  List<Object?> get props => [deviceStatuses, meshMessage];
}

class PublishMessage extends MQTTEvent {
  final String topic;
  final String message;

  PublishMessage(this.topic, this.message);

  @override
  List<Object?> get props => [topic, message];
}

// Custom Event untuk Subscribe topik root mesh network
class SubscribedMeshNetwork extends MQTTEvent {}

// Custom Event untuk menangani pesan masuk dari topik root mesh network //// TRIGGER SEKALI SAJA
class ProcessDeviceMessage extends MQTTEvent {}

// Custom Event untuk permintaan data dari device
class RequestDevicesData extends MQTTEvent {
  final String command; // contoh: 'getNode' atau 'getRSSI'

  RequestDevicesData({required this.command});

  @override
  List<Object?> get props => [command];
}

// Custom Event untuk mengubah status device (ON/OFF)
class SetDeviceState extends MQTTEvent {
  final String deviceId;
  final String value; // 'ON' atau 'OFF'

  SetDeviceState({required this.deviceId, required this.value});

  @override
  List<Object?> get props => [deviceId, value];
}

// Custom Event untuk kirim pesan teks ke semua device
class SendBroadcast extends MQTTEvent {
  final String message;

  SendBroadcast({required this.message});

  @override
  List<Object?> get props => [message];
}
