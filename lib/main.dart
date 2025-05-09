import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/routes.dart';
import 'core/constants/color_constants.dart';
import 'features/main_bnb/bloc/main_bnb_bloc.dart';
import 'features/mqtt/bloc/mqtt_bloc.dart';
import 'injections_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainBNBBloc>(
          create: (context) => sl()..add(TabChange(tabIndex: 0)),
        ),
        BlocProvider<MQTTBloc>(
          create: (context) => sl()..add(ConnectMQTT()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        theme: ThemeData(
          fontFamily: 'Lexend',
          scaffoldBackgroundColor: ColorConstants.lightBlueAppColor,
        ),
        initialRoute: '/',
      ),
    );
  }
}
