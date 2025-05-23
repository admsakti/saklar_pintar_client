import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../database/data/database_helper.dart';
import '../data/data_mqtt.dart';
import '../models/device_statuses.dart';
import '../models/mesh_message.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MQTTBloc extends Bloc<MQTTEvent, MQTTState> {
  final DataMQTT _dataMQTT;
  final DatabaseHelper _database;

  MQTTBloc(this._dataMQTT, this._database) : super(MQTTInitial()) {
    on<ConnectMQTT>(onConnect);
    on<MessageReceived>(onMessageReceived);
    on<PublishMessage>(onPublish);
    on<ProcessDeviceMessage>(onProcessDeviceMessage); // TRIGGER SEKALI SAJA
    on<SubscribedMeshNetwork>(onSubscribedMeshNetwork);
    on<RequestDevicesData>(onRequestDevicesData);
    on<SendBroadcast>(onSendBroadcast);
    on<SetDeviceState>(onSetDeviceState);
    on<SetDeviceSchedule>(onSetDeviceSchedule);
  }

  Future<void> onConnect(
    ConnectMQTT event,
    Emitter<MQTTState> emit,
  ) async {
    emit(MQTTConnecting());

    try {
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
    if (event.deviceStatuses != null) {
      if (state is MQTTConnected) {
        final current = state as MQTTConnected;
        final updatedMessages =
            List<DeviceStatuses>.from(current.deviceStatuses)
              ..add(event.deviceStatuses!);

        print('MQTT Received DeviceStatuses: ${event.deviceStatuses}');

        emit(current.copyWith(deviceStatuses: updatedMessages));
      } else {
        emit(MQTTConnected(deviceStatuses: [event.deviceStatuses!]));
      }
    } else if (event.meshMessage != null) {
      if (state is MQTTConnected) {
        final current = state as MQTTConnected;
        final updatedMessages = List<MeshMessage>.from(current.meshMessages)
          ..add(event.meshMessage!);

        print('MQTT Received MeshMessage: ${event.meshMessage}');

        emit(current.copyWith(meshMessages: updatedMessages));
      } else {
        emit(MQTTConnected(meshMessages: [event.meshMessage!]));
      }
    }
  }

  void onPublish(
    PublishMessage event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(event.topic, event.message);
  }

  // TRIGGER SEKALI SAJA
  void onProcessDeviceMessage(
    ProcessDeviceMessage event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.updates?.listen((event) async {
      final msg = event[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(msg.payload.message);
      final topic = event[0].topic;
      final segments = topic.split('/');

      // Parse device_id and info
      if (segments.length <= 5 &&
          segments[1] == 'gateway' &&
          segments[2] == 'nodes') {
        final macRoot = segments[0];
        final deviceId = segments[3];
        final infoType = segments[4]; // name, role, status, rssi

        print("macRoot: $macRoot");
        print("deviceId: $deviceId");
        print("infoType: $infoType");
        print("payload: $payload");

        final meshNetwork =
            await _database.getMeshNetworkByMacRoot(macRoot: macRoot);

        if (meshNetwork != null) {
          // jika meshNetwork sudah ada
          print("MQTT Mesh network '${meshNetwork.macRoot}' ada");

          final deviceExist =
              await _database.getDeviceByDeviceId(deviceId: deviceId);

          if (deviceExist == null) {
            if (infoType == "role") {
              // jika device belum di insert
              print("MQTT Device '$deviceId' belum ada, Insert ke database");
              await _database.insertDeviceWithMacRoot(
                macRoot: macRoot,
                deviceId: deviceId,
                name: deviceId,
                role: payload,
              );
            } else {
              print("MQTT Device '$deviceId' belum ada");
              return;
            }
          } else {
            print("MQTT Device '$deviceId' ada, kirim ke DeviceToggleWidget");

            // jika device sudah di insert
            final Map<String, dynamic> deviceData = {infoType: payload};

            print("MQTT Device data: $deviceData");

            add(
              MessageReceived(
                deviceStatuses: DeviceStatuses(
                  nodeId: deviceId,
                  value: json.encode(deviceData),
                ),
              ),
            ); // kembalikan ke massage received event
          }
        } else {
          print("MQTT Mesh network '$macRoot' tidak ada");
          return;
        }
      } else if (segments.length <= 3 &&
          segments[1] == 'gateway' &&
          segments[2] == 'msg') {
        // General messages
        final macRoot = segments[0];

        print("MQTT General msg: $payload from macRoot: $macRoot");

        add(
          MessageReceived(
            meshMessage: MeshMessage(
              nodeId: macRoot,
              value: payload,
            ),
          ),
        );
      }
    });
  }

// Urus logic ini agar tidak hardcode

  void onSubscribedMeshNetwork(
    SubscribedMeshNetwork event,
    Emitter<MQTTState> emit,
  ) {
    if (_dataMQTT.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      _dataMQTT.subscribe('${event.macRoot}/gateway/nodes/#');
      _dataMQTT.subscribe('${event.macRoot}/gateway/msg');
    } else {
      print("❌ MQTT not connected yet. Can't subscribe.");
    }
  }

  void onRequestDevicesData(
    RequestDevicesData event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(
      '${event.macRoot}/gateway/controls/request',
      event.command,
    );
  }

  void onSetDeviceState(
    SetDeviceState event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(
      '${event.macRoot}/gateway/controls/${event.deviceId}/set',
      event.value,
    );
  }

  void onSetDeviceSchedule(
    SetDeviceSchedule event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(
      '${event.macRoot}/gateway/controls/${event.deviceId}/schedule',
      event.scheduleList,
    );
  }

  void onSendBroadcast(
    SendBroadcast event,
    Emitter<MQTTState> emit,
  ) {
    _dataMQTT.publish(
      '${event.macRoot}/gateway/controls/broadcast',
      event.message,
    );
  }
}
