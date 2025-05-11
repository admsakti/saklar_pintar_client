part of 'main_bnb_bloc.dart';

abstract class MainBNBEvent {}

class TabChange extends MainBNBEvent {
  final int tabIndex;

  TabChange({required this.tabIndex});
}
