import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_bnb_event.dart';
part 'main_bnb_state.dart';

class MainBNBBloc extends Bloc<MainBNBEvent, MainBNBState> {
  MainBNBBloc() : super(MainBNBInitial(tabIndex: 0)) {
    on<MainBNBEvent>((event, emit) {
      if (event is TabChange) {
        emit(MainBNBInitial(tabIndex: event.tabIndex));
      }
    });
  }
}
