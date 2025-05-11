import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class DataMQTT {
  final MqttServerClient client;
  final String server;
  final String clientId;
  final int port;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isManuallyDisconnected = false;
  bool _isConnecting = false;

  DataMQTT({
    required this.server,
    required this.clientId,
    this.port = 1883,
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
      print('🔄 Connecting to $server:$port as $clientId ...');
      await client.connect();
    } catch (e) {
      print('❌ Connection exception: $e');
      print(
          '🔍 Connection return code: ${client.connectionStatus?.returnCode}');
      _disconnectOnError();
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }

    final status = client.connectionStatus?.state;
    if (status != MqttConnectionState.connected) {
      print('❌ Connection failed - status: $status');
      _disconnectOnError();
      _scheduleReconnect();
    } else {
      print('✅ Connected!');
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates => client.updates;

  void subscribe(String topic, [MqttQos qos = MqttQos.atMostOnce]) {
    print('📥 Subscribing to topic: $topic');
    client.subscribe(topic, qos);
  }

  void publish(String topic, String message,
      [MqttQos qos = MqttQos.atMostOnce]) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, qos, builder.payload!);
    print('📤 Published to $topic: $message');
  }

  void disconnect() {
    _isManuallyDisconnected = true;
    _connectivitySubscription.cancel(); // berhenti pantau
    client.disconnect();
    print('🔌 Disconnected manually');
  }

  void _scheduleReconnect() {
    const delay = Duration(seconds: 5);
    print('⏳ Reconnecting in ${delay.inSeconds} seconds...');
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
        connect();
      }
    });
  }

  void _disconnectOnError() {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      client.disconnect();
    }
  }

  void _onConnected() {
    print('🔗 Connected callback triggered');
    _isManuallyDisconnected = false;
  }

  void _onDisconnected() {
    print('🔌 Disconnected callback triggered');
    if (!_isManuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    print('✅ Subscribed to: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('❌ Failed to subscribe: $topic');
  }
}
