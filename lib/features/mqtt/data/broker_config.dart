import 'package:shared_preferences/shared_preferences.dart';

class BrokerConfig {
  static const _keyBroker = 'mqtt_broker';
  static const _keyPort = 'mqtt_port';

  static const defaultBroker = 'broker.emqx.io';
  static const defaultPort = 1883;

  /// Menyimpan broker dan port
  static Future<bool> saveBroker(String broker, int port) async {
    print("Save MQTT broker '$broker' in port '$port'");

    final prefs = await SharedPreferences.getInstance();
    final successBroker = await prefs.setString(_keyBroker, broker);
    final successPort = await prefs.setInt(_keyPort, port);

    return successBroker && successPort;
  }

  /// Memuat broker dan port. Jika belum ada, simpan nilai default.
  static Future<(String, int)> loadBroker() async {
    final prefs = await SharedPreferences.getInstance();
    // final broker = prefs.getString(_keyBroker) ?? defaultBroker;
    // final port = prefs.getInt(_keyPort) ?? defaultPort;

    String? broker = prefs.getString(_keyBroker);
    int? port = prefs.getInt(_keyPort);

    if (broker == null || port == null) {
      // Set default values on first load
      await prefs.setString(_keyBroker, defaultBroker);
      await prefs.setInt(_keyPort, defaultPort);
      broker = defaultBroker;
      port = defaultPort;
    }

    print("Load MQTT broker '$broker' with port '$port'");
    return (broker, port);
  }

  /// Mereset broker dan port ke nilai default
  static Future<bool> resetBroker() async {
    print("Reset MQTT broker to default");

    final prefs = await SharedPreferences.getInstance();
    final successBroker = await prefs.setString(_keyBroker, defaultBroker);
    final successPort = await prefs.setInt(_keyPort, defaultPort);

    return successBroker && successPort;
  }
}
