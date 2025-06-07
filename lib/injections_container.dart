import 'dart:math';

import 'package:get_it/get_it.dart';

import 'features/database/bloc/device/device_bloc.dart';
import 'features/database/bloc/device_schedule/device_schedule_bloc.dart';
import 'features/database/bloc/mesh_network/mesh_network_bloc.dart';
import 'features/database/data/database_helper.dart';
import 'features/main_bnb/bloc/main_bnb_bloc.dart';
import 'features/mqtt/bloc/mqtt_bloc.dart';
import 'features/mqtt/data/broker_config.dart';
import 'features/mqtt/data/data_mqtt.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final databaseClient = DatabaseHelper();

  // Ambil alamat broker dari SharedPreferences
  final (broker, port) = await BrokerConfig.loadBroker();

  print("Injections broker '$broker' with port '$port'");

  // Buat DataMQTT dulu tanpa MQTTBloc
  final mqttClient = DataMQTT(
    server: broker,
    port: port,
    clientId: 'MeshNetClient${Random().nextInt(10000)}',
  );

  // Baru buat MQTTBloc-nya
  final mqttBloc = MQTTBloc(mqttClient, databaseClient);

  // Inject bloc-nya ke dalam mqttClient
  mqttClient.mqttBloc = mqttBloc;

  // BLOC MQTT
  sl.registerSingleton(mqttBloc);

  // BLOC mainBNB
  sl.registerSingleton(MainBNBBloc());

  // BLOC Database
  sl.registerSingleton(
    MeshNetworkBloc(databaseClient),
  );
  sl.registerSingleton(
    DeviceBloc(databaseClient),
  );
  sl.registerSingleton(
    DeviceScheduleBloc(databaseClient),
  );
}
