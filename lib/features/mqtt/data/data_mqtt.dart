import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class DataMQTT {
  final MqttServerClient client;
  final String server;
  final String clientId;
  final int port;

  DataMQTT({
    required this.server,
    required this.clientId,
    this.port = 1883,
  }) : client = MqttServerClient.withPort(server, clientId, port) {
    _initialize();
  }

  void _initialize() {
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    // client.autoReconnect = true;
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
    try {
      print('🔄 Connecting to $server:$port as $clientId ...');
      await client.connect();
    } catch (e) {
      print('❌ Connection exception: $e');
      print(
          '🔍 Connection return code: ${client.connectionStatus?.returnCode}');
      _disconnectOnError();
      return;
    }

    final status = client.connectionStatus?.state;
    if (status != MqttConnectionState.connected) {
      print('❌ Connection failed - status: $status');
      _disconnectOnError();
      return;
    }

    print('✅ Connected!');
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
    client.disconnect();
    print('🔌 Disconnected manually');
  }

  void _disconnectOnError() {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      client.disconnect();
    }
  }

  void _onConnected() {
    print('🔗 Connected callback triggered');
  }

  void _onDisconnected() {
    print('🔌 Disconnected callback triggered');
  }

  void _onSubscribed(String topic) {
    print('✅ Subscribed to: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('❌ Failed to subscribe: $topic');
  }
}
