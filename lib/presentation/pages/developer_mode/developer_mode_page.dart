import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restart_app/restart_app.dart';
import '../../../core/constants/color_constants.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';
import '../../../features/mqtt/data/broker_config.dart';

class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  final _brokerController = TextEditingController();
  final _portController = TextEditingController();
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    BrokerConfig.loadBroker().then((value) {
      _brokerController.text = value.$1;
      _portController.text = value.$2.toString();
    });

    _brokerController.addListener(_onUserInteraction);
  }

  void _onUserInteraction() {
    setState(() {
      _hasUserInteracted = true;
    });
  }

  void _saveAndRestart() async {
    final broker = _brokerController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 1883;

    final saveSuccess = await BrokerConfig.saveBroker(broker, port);

    if (saveSuccess) {
      _onShowRestartDialog();
    }
  }

  void _onShowRestartDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: ColorConstants.lightBlueAppColor,
          title: const Text(
            "Restart Mesh-Net App",
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Alamat Broker MQTT disimpan. Lakukan restart aplikasi untuk menerapkan konfigurasi baru"),
            ],
          ),
          actions: [
            TextButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  Colors.green,
                ),
              ),
              onPressed: () {
                print("MQTT restart aplikasi!");
                // Untuk development, bisa restart secara manual. Navigator.pop menutup pop-up
                // Navigator.pop(context);
                // Navigator.pop(context);
                // Matikan dulu saat debug biar tidak close aplikasinya
                Restart.restartApp();
              },
              child: Text(
                'Restart Now!',
                style: TextStyle(
                  color: ColorConstants.blackAppColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        title: const Text('Developer Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_backup_restore_rounded),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: ColorConstants.lightBlueAppColor,
                title: const Text(
                  "Reset MQTT Broker",
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Yakin ingin mereset alamat Broker MQTT ke setelan default?"),
                  ],
                ),
                actions: [
                  TextButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Colors.green,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Tidak',
                      style: TextStyle(
                        color: ColorConstants.blackAppColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Colors.red,
                      ),
                    ),
                    onPressed: () async {
                      final success = await BrokerConfig.resetBroker();
                      if (success) {
                        _onShowRestartDialog();
                      }
                    },
                    child: Text(
                      'Ya!',
                      style: TextStyle(
                        color: ColorConstants.blackAppColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            tooltip: "Reset MQTT Broker",
          ),
          const SizedBox(width: 5),
          BlocBuilder<MQTTBloc, MQTTState>(
            builder: (context, state) {
              Color indicatorColor;
              // Dart versi 3 memperkenalkan pattern matching
              switch (state) {
                case MQTTConnecting _:
                  indicatorColor = Colors.orange;
                  break;
                case MQTTConnected _:
                  indicatorColor = Colors.green;
                  break;
                case MQTTDisconnected _:
                  indicatorColor = Colors.red;
                  break;
                default:
                  indicatorColor = Colors.grey;
              }

              return Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor,
                  boxShadow: [
                    BoxShadow(
                      color: indicatorColor.withOpacity(0.6),
                      spreadRadius: 2,
                      blurRadius: 6,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // MQTT Broker Text Field
                TextField(
                  controller: _brokerController,
                  decoration: InputDecoration(
                    labelText: 'MQTT Broker',
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    errorText:
                        _brokerController.text.isEmpty && _hasUserInteracted
                            ? 'MQTT Broker cannot be empty'
                            : null,
                  ),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
                SizedBox.fromSize(size: const Size.fromHeight(20)),

                // MQTT Port Text Field
                TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'MQTT Port',
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
                SizedBox.fromSize(size: const Size.fromHeight(40)),
                Material(
                  color: _brokerController.text.isNotEmpty
                      ? ColorConstants.whiteAppColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _brokerController.text.isNotEmpty
                        ? () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor:
                                    ColorConstants.lightBlueAppColor,
                                title: const Text(
                                  "Change MQTT Broker",
                                ),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        "Yakin ingin mengganti alamat Broker MQTT?"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll<Color>(
                                        Colors.green,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Tidak',
                                      style: TextStyle(
                                        color: ColorConstants.blackAppColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll<Color>(
                                        Colors.red,
                                      ),
                                    ),
                                    onPressed: () => _saveAndRestart(),
                                    child: Text(
                                      'Ya!',
                                      style: TextStyle(
                                        color: ColorConstants.blackAppColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 64,
                      child: Center(
                        child: Text(
                          "Save & Restart Device",
                          style: TextStyle(
                            color: _brokerController.text.isNotEmpty
                                ? ColorConstants.darkBlueAppColor
                                : Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
