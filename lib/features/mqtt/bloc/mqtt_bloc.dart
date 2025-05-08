import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../data/data_mqtt.dart';
import '../models/node_message.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MQTTBloc extends Bloc<MQTTEvent, MQTTState> {
  final DataMQTT _dataMQTT;

  MQTTBloc(this._dataMQTT) : super(MQTTInitial()) {
    on<ConnectMQTT>(onConnect);
    on<MessageReceived>(onMessageReceived);
    on<PublishMessage>(onPublish);
    on<RequestDeviceData>(onRequestDeviceData);
    on<SendBroadcast>(onSendBroadcast);
    on<SetDeviceState>(onSetDeviceState);
  }

  Future<void> onConnect(ConnectMQTT event, Emitter<MQTTState> emit) async {
    emit(MQTTConnecting());

    try {
      await _dataMQTT.connect();
      _dataMQTT.subscribe('painlessMesh/gateway/nodes/#');
      _dataMQTT.subscribe('painlessMesh/gateway/msg');

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

          print(deviceData.toString());

          add(
            MessageReceived(
              NodeMessage(
                nodeId: deviceId,
                value: json.encode(deviceData),
              ),
            ),
          );
        } else if (topic == 'painlessMesh/gateway/msg') {
          // General messages
          add(MessageReceived(NodeMessage(
            nodeId: 'broadcast',
            value: payload,
          )));
        }
      });

      emit(MQTTConnected()); // Emit initial loaded state
    } catch (e) {
      emit(MQTTError('Connection failed: $e'));
    }
  }

  void onMessageReceived(MessageReceived event, Emitter<MQTTState> emit) {
    if (state is MQTTConnected) {
      final current = state as MQTTConnected;
      final updatedMessages = List<NodeMessage>.from(current.messages)
        ..add(event.message);

      emit(current.copyWith(messages: updatedMessages));
    } else {
      emit(MQTTConnected(messages: [event.message]));
    }
  }

  void onPublish(PublishMessage event, Emitter<MQTTState> emit) {
    _dataMQTT.publish(event.topic, event.message);
  }

  void onRequestDeviceData(RequestDeviceData event, Emitter<MQTTState> emit) {
    _dataMQTT.publish('painlessMesh/gateway/controls/request', event.command);
  }

  void onSetDeviceState(SetDeviceState event, Emitter<MQTTState> emit) {
    _dataMQTT.publish(
      'painlessMesh/gateway/controls/${event.deviceId}/set',
      event.value,
    );
  }

  void onSendBroadcast(SendBroadcast event, Emitter<MQTTState> emit) {
    _dataMQTT.publish('painlessMesh/gateway/controls/broadcast', event.message);
  }
}
