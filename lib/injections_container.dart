import 'package:get_it/get_it.dart';
import 'features/database/bloc/device/device_bloc.dart';
import 'features/database/bloc/mesh_network/mesh_network_bloc.dart';
import 'features/database/data/database_helper.dart';

import 'core/constants/path_constants.dart';
import 'features/main_bnb/bloc/main_bnb_bloc.dart';
import 'features/mqtt/bloc/mqtt_bloc.dart';
import 'features/mqtt/data/data_mqtt.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final mqttClient = DataMQTT(
    server: baseMQTTBroker,
    clientId: baseClientID,
    port: baseMQTTPort,
  );

  final datatabaseClient = DatabaseHelper();

  // BLOC mainBNB
  sl.registerSingleton(MainBNBBloc());

  // BLOC MQTT
  sl.registerSingleton(
    MQTTBloc(mqttClient),
  );

  // BLOC Database
  sl.registerSingleton(
    MeshNetworkBloc(datatabaseClient),
  );
  sl.registerSingleton(
    DeviceBloc(datatabaseClient),
  );
}
