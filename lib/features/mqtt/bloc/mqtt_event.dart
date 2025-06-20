part of 'mqtt_bloc.dart';

abstract class MQTTEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectMQTT extends MQTTEvent {}

class MQTTConnectingEvent extends MQTTEvent {}

class MQTTConnectedEvent extends MQTTEvent {}

class MQTTDisconnectedEvent extends MQTTEvent {
  final String reason;

  MQTTDisconnectedEvent(this.reason);

  @override
  List<Object?> get props => [reason];
}

class MessageReceived extends MQTTEvent {
  final DeviceStatuses? deviceStatuses;
  final MeshMessage? meshMessage;

  MessageReceived({
    this.deviceStatuses,
    this.meshMessage,
  }) : assert(
          deviceStatuses != null || meshMessage != null,
          'Either deviceStatuses or meshMessage must be provided',
        );

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
class SubscribedMeshNetwork extends MQTTEvent {
  final String macRoot;

  SubscribedMeshNetwork({required this.macRoot});

  @override
  List<Object?> get props => [macRoot];
}

// Custom Event untuk Unsubscribe topik root mesh network
class UnsubscribedMeshNetwork extends MQTTEvent {
  final String macRoot;

  UnsubscribedMeshNetwork({required this.macRoot});

  @override
  List<Object?> get props => [macRoot];
}

// Custom Event untuk Unsubscribe semua topik yang terhubung
class UnsubscribedAll extends MQTTEvent {}

// Custom Event untuk menangani pesan masuk dari topik root mesh network
class ProcessDeviceMessage extends MQTTEvent {}

// Custom Event untuk permintaan data dari all device
class RequestDevicesData extends MQTTEvent {
  final String macRoot;
  final String command; // contoh: 'getNode' atau 'getRSSI'

  RequestDevicesData({required this.macRoot, required this.command});

  @override
  List<Object?> get props => [macRoot, command];
}

// Custom Event untuk permintaan data dari single device
class RequestDeviceData extends MQTTEvent {
  final String macRoot;
  final String nodeId;

  RequestDeviceData({required this.macRoot, required this.nodeId});

  @override
  List<Object?> get props => [macRoot, nodeId];
}

// Custom Event untuk mengubah status device (ON/OFF)
class SetDeviceState extends MQTTEvent {
  final String macRoot;
  final String nodeId;
  final String value; // 'ON' atau 'OFF'

  SetDeviceState({
    required this.macRoot,
    required this.nodeId,
    required this.value,
  });

  @override
  List<Object?> get props => [macRoot, nodeId, value];
}

// Custom Event untuk menambahkan device schedule atau timer state saklar
class SetDeviceSchedule extends MQTTEvent {
  final String macRoot;
  final String nodeId;
  final String scheduleList; // String JSON list schedule

  SetDeviceSchedule({
    required this.macRoot,
    required this.nodeId,
    required this.scheduleList,
  });

  @override
  List<Object?> get props => [macRoot, nodeId, scheduleList];
}

// Custom Event untuk kirim pesan teks ke semua device
class SendBroadcast extends MQTTEvent {
  final String macRoot;
  final String message;

  SendBroadcast({required this.macRoot, required this.message});

  @override
  List<Object?> get props => [macRoot, message];
}
