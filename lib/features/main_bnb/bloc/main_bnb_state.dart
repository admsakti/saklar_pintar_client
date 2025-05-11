part of 'main_bnb_bloc.dart';

abstract class MainBNBState {
  final int tabIndex;

  MainBNBState({required this.tabIndex});
}

class MainBNBInitial extends MainBNBState {
  MainBNBInitial({required super.tabIndex});
}
