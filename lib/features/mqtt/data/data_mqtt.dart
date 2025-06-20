import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../bloc/mqtt_bloc.dart';

class DataMQTT {
  final MqttServerClient client;
  final String server;
  final String clientId;
  final int port;

  final Set<String> _subscribedTopics = {};

  late MQTTBloc mqttBloc; // Akan di-set setelah dibuat
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isManuallyDisconnected = false;
  bool _isConnecting = false;

  DataMQTT({
    required this.server,
    required this.clientId,
    this.port = 1883, // Default MQTT Port
  }) : client = MqttServerClient.withPort(server, clientId, port) {
    _initialize();
    _monitorConnectivity(); // Mulai pantau koneksi
  }

  void _initialize() {
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.autoReconnect = false;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    client.onSubscribeFail = _onSubscribeFail;
    client.onUnsubscribed = _onUnsubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;
  }

  Future<void> connect() async {
    if (_isConnecting ||
        client.connectionStatus?.state == MqttConnectionState.connected) return;
    _isConnecting = true;

    try {
      print('🔄 MQTT Connecting to $server:$port as $clientId ...');
      mqttBloc.add(MQTTConnectingEvent()); // Bloc Connecting event
      await client.connect();
    } catch (e) {
      print('❌ MQTT Connection exception: $e');
      print(
          '🔍 MQTT Connection return code: ${client.connectionStatus?.returnCode}');
      _disconnectOnError();
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }

    final status = client.connectionStatus?.state;
    if (status != MqttConnectionState.connected) {
      print('❌ MQTT Connection failed - status: $status');
      _disconnectOnError();
      _scheduleReconnect();
    } else {
      print('✅ MQTT Connected!');
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates => client.updates;

  void subscribe(String topic, [MqttQos qos = MqttQos.atMostOnce]) {
    print('📥 MQTT Subscribing to topic: $topic');
    client.subscribe(topic, qos);
    _subscribedTopics.add(topic);
  }

  void unsubscribe(String topic) {
    print('📤 MQTT Unsubscribing from topic: $topic');
    client.unsubscribe(topic);
    _subscribedTopics.remove(topic);
  }

  void unsubscribeAll() {
    for (final topic in _subscribedTopics) {
      print('📤 MQTT Unsubscribing from topic: $topic');
      client.unsubscribe(topic);
    }
    _subscribedTopics.clear();
  }

  void publish(String topic, String message,
      [MqttQos qos = MqttQos.atMostOnce]) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, qos, builder.payload!);
    print('📤 MQTT Published to $topic: $message');
  }

  void disconnect() {
    _isManuallyDisconnected = true;
    _connectivitySubscription.cancel(); // berhenti pantau
    client.disconnect();
    // Bloc Disconnected event
    mqttBloc.add(MQTTDisconnectedEvent('Disconnect manually'));
    print('🔌 MQTT Disconnected manually');
  }

  void _scheduleReconnect() {
    const delay = Duration(seconds: 5);
    print('⏳ MQTT Reconnecting in ${delay.inSeconds} seconds...');
    mqttBloc.add(MQTTConnectingEvent()); // Bloc Connecting event
    Future.delayed(delay, () {
      if (!_isManuallyDisconnected &&
          client.connectionStatus?.state != MqttConnectionState.connected) {
        connect();
      }
    });
  }

  void _monitorConnectivity() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (!_isManuallyDisconnected &&
          result.contains(ConnectivityResult.none) &&
          client.connectionStatus?.state != MqttConnectionState.connected) {
        print('🌐 Internet reconnected - trying to reconnect MQTT...');
        mqttBloc.add(MQTTConnectingEvent()); // Bloc Connecting event
        connect();
      }
    });
  }

  void _disconnectOnError() {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      client.disconnect();
      // Bloc Disconnected event
      mqttBloc.add(MQTTDisconnectedEvent('Disconnect on error'));
    }
  }

  void _onConnected() {
    print('🔗 MQTT Connected callback triggered');
    mqttBloc.add(MQTTConnectedEvent()); // Bloc Connected event
    _isManuallyDisconnected = false;
  }

  void _onDisconnected() {
    print('🔌 MQTT Disconnected callback triggered');
    // Bloc Disconnected event
    mqttBloc.add(MQTTDisconnectedEvent('Connection lost'));
    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    print('✅ MQTT Subscribed to: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('❌ MQTT Failed to subscribe: $topic');
  }

  void _onUnsubscribed(String? topic) {
    print('❌ MQTT Unsubscribed topic: $topic');
  }
}
