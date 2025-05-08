part of 'mqtt_bloc.dart';

abstract class MQTTEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectMQTT extends MQTTEvent {}

class MessageReceived extends MQTTEvent {
  final NodeMessage message;
  MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class PublishMessage extends MQTTEvent {
  final String topic;
  final String message;
  PublishMessage(this.topic, this.message);

  @override
  List<Object?> get props => [topic, message];
}

// Custom Event untuk permintaan data dari device
class RequestDeviceData extends MQTTEvent {
  final String command; // contoh: 'getNode' atau 'getRSSI'

  RequestDeviceData(this.command);

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

  SendBroadcast(this.message);

  @override
  List<Object?> get props => [message];
}
