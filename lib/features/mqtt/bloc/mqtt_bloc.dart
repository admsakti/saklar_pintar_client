import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../data/data_mqtt.dart';
import '../models/device_statuses.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MQTTBloc extends Bloc<MQTTEvent, MQTTState> {
  final DataMQTT _dataMQTT;

  MQTTBloc(this._dataMQTT) : super(MQTTInitial()) {
    on<ConnectMQTT>(onConnect);
    on<MessageReceived>(onMessageReceived);
    on<PublishMessage>(onPublish);
    on<SubscribedMeshNetwork>(onSubscribedMeshNetwork);
    on<DeviceReceivedMessage>(onDeviceReceivedMessage);
    on<RequestDevicesData>(onRequestDevicesData);
    on<SendBroadcast>(onSendBroadcast);
    on<SetDeviceState>(onSetDeviceState);
  }

  Future<void> onConnect(
    ConnectMQTT event,
    Emitter<MQTTState> emit,
  ) async {
    emit(MQTTConnecting());

    try {
      // print("MQTT onConnect dijalankan");
      await _dataMQTT.connect();

      emit(MQTTConnected());
    } catch (e) {
      emit(MQTTError('Connection failed: $e'));
    }
  }

  void onMessageReceived(
    MessageReceived event,
    Emitter<MQTTState> emit,
  ) {
    if (state is MQTTConnected) {
      final current = state as MQTTConnected;
      final updatedMessages = List<DeviceStatuses>.from(current.messages)
        ..add(event.message);

      emit(current.copyWith(messages: updatedMessages));
    } else {
      emit(MQTTConnected(messages: [event.message]));
    }
  }

  void onPublish(
    PublishMessage event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(event.topic, event.message);
  }

  void onSubscribedMeshNetwork(
    SubscribedMeshNetwork event,
    Emitter<MQTTState> emit,
  ) {
    print(" MQTT Subcribe mesh network dijalankan");

    if (_dataMQTT.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      _dataMQTT.subscribe('painlessMesh/gateway/nodes/#');
      _dataMQTT.subscribe('painlessMesh/gateway/msg');
    } else {
      print("❌ MQTT not connected yet. Can't subscribe.");
    }
  }

  void onDeviceReceivedMessage(
    DeviceReceivedMessage event,
    Emitter<MQTTState> emit,
  ) {
    // filter Device lagi karena device yang sama malah bisa buat widget (1 device 1 widget aja, jika sama update sebelumnya)
    _dataMQTT.updates?.listen((event) {
      final msg = event[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(msg.payload.message);
      final topic = event[0].topic;
      final segments = topic.split('/');

      // Parse device_id and info
      if (segments.length >= 5 &&
          segments[1] == 'gateway' &&
          segments[2] == 'nodes') {
        final deviceId = segments[3];
        // final infoType = segments.length >= 6 ? segments[5] : '';
        final infoType = segments[4];

        final Map<String, dynamic> deviceData = {
          'device_id': deviceId,
          infoType: payload
        };

        print("Device received msg ${deviceData.toString()}");

        add(
          MessageReceived(
            DeviceStatuses(
              nodeId: deviceId,
              value: json.encode(deviceData),
            ),
          ),
        ); // kembalikan ke massage received event
      } else if (topic == 'painlessMesh/gateway/msg') {
        // General messages

        print("General msg $payload");

        add(MessageReceived(DeviceStatuses(
          nodeId: 'broadcast',
          value: payload,
        )));
      }
    });
  }

  void onRequestDevicesData(
    RequestDevicesData event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish('painlessMesh/gateway/controls/request', event.command);
  }

  void onSetDeviceState(
    SetDeviceState event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(
      'painlessMesh/gateway/controls/${event.deviceId}/set',
      event.value,
    );
  }

  void onSendBroadcast(
    SendBroadcast event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish('painlessMesh/gateway/controls/broadcast', event.message);
  }
}
