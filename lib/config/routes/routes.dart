import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Dependency Injection
import '../../../injections_container.dart';
// Arguments
import '../arguments/device_arguments.dart';
// BLOC
import '../../features/database/bloc/device/device_bloc.dart';
import '../../features/database/bloc/mesh_network/mesh_network_bloc.dart';
import '../../features/mqtt/bloc/mqtt_bloc.dart';
// Pages
import '../../presentation/pages/device_dashboard/device_dashboard.dart';
import '../../presentation/pages/device_provisioning/device_provisioning_page.dart';
import '../../presentation/pages/main_bnb/main_bnb_page.dart';
import '../../presentation/pages/splash/splash_screen.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      // splash Screen
      case '/':
        return _materialRoute(const SplashScreen());

      // Home Section (Home Page and Setting Page)
      case '/MainBNB':
        final context = settings.arguments as BuildContext;
        return _materialRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider<MeshNetworkBloc>.value(
                value: sl<MeshNetworkBloc>()
                  ..add(
                    GetMeshNetworks(),
                  ),
              ),
              BlocProvider<DeviceBloc>.value(
                value: sl<DeviceBloc>()
                  ..add(
                    GetDevices(),
                  ),
              ),
              BlocProvider.value(
                value: BlocProvider.of<MQTTBloc>(context)
                  ..add(
                    ProcessDeviceMessage(), // TRIGGER SEKALI SAJA,
                  ),
              ),
            ],
            child: const MainBNBPage(),
          ),
        );

      // Provisioning
      case '/DeviceProvisioning':
        final context = settings.arguments as BuildContext;
        return _materialRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: BlocProvider.of<MeshNetworkBloc>(context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<MQTTBloc>(context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<DeviceBloc>(context),
              ),
            ],
            child: const DeviceProvisioningPage(),
          ),
        );

      //Dashboard Details
      case '/DeviceDashboard':
        final args = settings.arguments as DeviceArguments;
        return _materialRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: BlocProvider.of<MeshNetworkBloc>(args.context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<MQTTBloc>(args.context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<DeviceBloc>(args.context),
              ),
            ],
            child: DeviceDashboardPage(
              device: args.device,
              currentStatus: args.currentStatus,
              currentOnline: args.currentOnline,
              currentRSSI: args.currentRSSI,
            ),
          ),
        );

      default:
        return _materialRoute(const SplashScreen());
    }
  }

  static MaterialPageRoute _materialRoute(Widget page) {
    return MaterialPageRoute(builder: (context) => page);
  }
}
