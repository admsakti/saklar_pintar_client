import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/bloc/device/device_bloc.dart';
import '../../../features/database/bloc/mesh_network/mesh_network_bloc.dart';
import '../../../features/mqtt/bloc/mqtt_bloc.dart';

class DeviceProvisioningPage extends StatefulWidget {
  const DeviceProvisioningPage({
    super.key,
  });

  @override
  State<DeviceProvisioningPage> createState() => _DeviceProvisioningPageState();
}

class _DeviceProvisioningPageState extends State<DeviceProvisioningPage>
    with WidgetsBindingObserver {
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  final _meshNameController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isMeshNameValid = false;
  bool _isSSIDValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordHidden = true;
  bool _hasUserInteracted = false;

  String? _wifiBSSID = '00:00:00:00:00:00';
  String? responseBSSID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestLocationPermission(); // Request lokasi untuk mendapatkan ssid dan bssid
    _listenToConnectivityChanges(); // Stream WiFi

    _meshNameController.addListener(_onUserInteraction);
    _ssidController.addListener(_onUserInteraction);
    _passwordController.addListener(_onUserInteraction);
  }

  void _onUserInteraction() {
    setState(() {
      _hasUserInteracted = true;
      _validateInputs();
    });
  }

  void _validateInputs() {
    _isMeshNameValid = _meshNameController.text.isNotEmpty;
    _isSSIDValid = _ssidController.text.isNotEmpty;
    _isPasswordValid = _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 8;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  bool get _isFormValid => _isMeshNameValid && _isSSIDValid && _isPasswordValid;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();

    _meshNameController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Cek ulang jika kembali dari settings
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        print("Izin lokasi diberikan setelah kembali dari settings");
        _getConnectedSSID();
      }
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      print("Izin lokasi tidak diberikan");
      await openAppSettings(); // Arahkan ke settings
      return;
    }

    print("Izin lokasi diberikan");
    _getConnectedSSID();
  }

  Future<void> _getConnectedSSID() async {
    print("_getConnectedSSID Dijalankan!");
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      print("Koneksi dengan WiFi!");
      final info = NetworkInfo();
      final ssid = await info.getWifiName();
      final bssid = await info.getWifiBSSID();

      print("raw-ssid:$ssid");
      print("bssid:$bssid");

      if (ssid != null) {
        print("cleaned-ssid:${ssid.trim().replaceAll(RegExp(r'^"|"$'), '')}");
        setState(() {
          _ssidController.text = ssid.trim().replaceAll(RegExp(r'^"|"$'), '');
          _wifiBSSID = bssid;
        });
      }
    }
  }

  void _listenToConnectivityChanges() {
    // Dengarkan perubahan koneksi
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.wifi)) {
        print("Stream konektifitas WiFi dijalankan");
        _getConnectedSSID(); // Perbarui SSID jika terhubung ke WiFi
      } else {
        setState(() {
          _ssidController.text = ''; // Kosongkan jika tidak terhubung
        });
      }
    });
  }

  Future<void> _startProvisioning() async {
    final provisioner = Provisioner.espTouch();

    provisioner.listen((response) {
      Navigator.of(context).pop(response);
    });

    provisioner.start(ProvisioningRequest.fromStrings(
      ssid: _ssidController.text.trim(),
      bssid: _wifiBSSID ?? '00:00:00:00:00:00',
      password: _passwordController.text.trim(),
    ));

    ProvisioningResponse? response = await showDialog<ProvisioningResponse>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorConstants.lightBlueAppColor,
          title: const Text('Mesh-Net Device'),
          content: const Text('Provisioning started. Please wait...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ColorConstants.blackAppColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (provisioner.running) {
      provisioner.stop();
    }

    if (response != null) {
      print(response.bssidText);

      await _onSaveDataMeshNetwork(response);
    }
  }

  _onSaveDataMeshNetwork(ProvisioningResponse response) async {
    setState(() {
      responseBSSID = response.bssidText;
    });
    context.read<MeshNetworkBloc>().add(
          InsertMeshNetwork(
            macRoot: response.bssidText,
            meshName: _meshNameController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        leading: Builder(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onBackButtonTapped(context),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
          ),
        ),
        title: const Text("Device Provisioning"),
        centerTitle: true,
      ),
      body: BlocListener<MeshNetworkBloc, MeshNetworkState>(
        listener: (context, state) {
          if (state is MeshNetworkLoading) {
            const Center(child: CircularProgressIndicator());
          } else if (state is SaveMeshNetworkSuccess) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return PopScope(
                  canPop: false,
                  child: AlertDialog(
                    backgroundColor: ColorConstants.lightBlueAppColor,
                    title: const Text('Device provisioned'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Mesh-Net Device successfully connected to the ${_ssidController.text.trim()} network as Gateway!'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          print("Provisioning Done! macRoot : $responseBSSID");

                          context.read<MQTTBloc>().add(
                                SubscribedMeshNetwork(macRoot: responseBSSID!),
                              );
                          context.read<MQTTBloc>().add(
                                RequestDevicesData(
                                  macRoot: responseBSSID!,
                                  command: 'getNodes',
                                ),
                              );
                          context.read<MeshNetworkBloc>().add(
                                GetMeshNetworks(),
                              );
                          context.read<DeviceBloc>().add(GetDevices());
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _meshNameController.clear();
                          _ssidController.clear();
                          _passwordController.clear();
                        },
                        child: Text(
                          'OK',
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
              },
            );
          } else if (state is MeshNetworkFailure) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return PopScope(
                  canPop: false,
                  child: AlertDialog(
                    backgroundColor: ColorConstants.lightBlueAppColor,
                    title: const Text('Error Device provisioned'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const Text(
                            'Mohon Reset Mesh-Net Device dan ulangi proses provisioning'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _meshNameController.clear();
                          _ssidController.clear();
                          _passwordController.clear();
                        },
                        child: Text(
                          'OK',
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
              },
            );
          }
          Container();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cell_tower,
                    size: 80,
                    color: ColorConstants.darkBlueAppColor,
                  ),
                  SizedBox.fromSize(size: const Size.fromHeight(40)),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorConstants.blackAppColor,
                      ),
                      children: const [
                        TextSpan(text: 'Connect your '),
                        TextSpan(
                          text: 'Mesh-Net Device\n',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: 'to WiFi network using'),
                        TextSpan(
                          text: ' ESP-Provisioning.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  SizedBox.fromSize(size: const Size.fromHeight(60)),

                  // Mesh Devices Name Text Field
                  TextField(
                    controller: _meshNameController,
                    decoration: InputDecoration(
                      hintText: 'Mesh devices name',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
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
                      errorText: !_isMeshNameValid && _hasUserInteracted
                          ? 'Mesh Name cannot be empty'
                          : null,
                    ),
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  SizedBox.fromSize(size: const Size.fromHeight(20)),

                  // SSID Text Field
                  TextField(
                    controller: _ssidController,
                    decoration: InputDecoration(
                      hintText: 'SSID (Network name)',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
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
                      suffixIcon: IconButton(
                        onPressed: () {
                          AppSettings.openAppSettings(
                              type: AppSettingsType.wifi);
                          // AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
                        },
                        icon: const Icon(Icons.wifi),
                        tooltip: "Open WiFi Settings",
                      ),
                      errorText: !_isSSIDValid && _hasUserInteracted
                          ? 'SSID cannot be empty'
                          : null,
                    ),
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  SizedBox.fromSize(size: const Size.fromHeight(20)),

                  // Password Text Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordHidden,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
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
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _isPasswordHidden
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        tooltip: "Password Visibility",
                      ),
                      errorText: !_isPasswordValid && _hasUserInteracted
                          ? 'Password must be 8 or more characters'
                          : null,
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  SizedBox.fromSize(size: const Size.fromHeight(60)),

                  // Provisioning Button
                  Material(
                    color: _isFormValid
                        ? ColorConstants.whiteAppColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _isFormValid ? () => _startProvisioning() : null,
                      // Dummy untuk proses debugging
                      // onTap: _isFormValid
                      //     ? () => _onDummySaveDataMeshNetwork()
                      //     : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        height: 64,
                        child: Center(
                          child: Text(
                            "Start Provisioning",
                            style: TextStyle(
                              color: _isFormValid
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
                  SizedBox.fromSize(size: const Size.fromHeight(40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dummy untuk proses debugging
  // _onDummySaveDataMeshNetwork() async {
  //   print("_onDummySaveDataMeshNetwork dijalankan!");
  //   setState(() {
  //     responseBSSID = 'a0:b7:65:dd:12:00';
  //   });
  //   context.read<MeshNetworkBloc>().add(
  //         InsertMeshNetwork(
  //           macRoot: 'a0:b7:65:dd:12:00',
  //           meshName: _meshNameController.text.trim(),
  //         ),
  //       );
  // }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }
}
