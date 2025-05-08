import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/main_bnb/bloc/main_bnb_bloc.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';

class MainBNBPage extends StatelessWidget {
  const MainBNBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBNBBloc, MainBNBState>(
      builder: (context, state) {
        return Scaffold(
          body: bottomNavPages.elementAt(state.tabIndex),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: BottomNavigationBar(
              backgroundColor: ColorConstants.darkBlueAppColor,
              items: bottomNavItems,
              currentIndex: state.tabIndex,
              selectedItemColor: ColorConstants.whiteAppColor,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              selectedIconTheme: const IconThemeData(size: 28),
              unselectedItemColor: Colors.black54,
              onTap: (index) {
                BlocProvider.of<MainBNBBloc>(context).add(
                  TabChange(tabIndex: index),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

List<BottomNavigationBarItem> bottomNavItems = const <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    label: 'Settings',
  ),
];

const List<Widget> bottomNavPages = <Widget>[
  HomePage(),
  SettingsPage(),
];
