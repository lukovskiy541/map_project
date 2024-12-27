import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'coordinates_event.dart';
part 'coordinates_state.dart';

class CoordinatesBloc extends Bloc<CoordinatesEvent, CoordinatesState> {
  CoordinatesBloc() : super(CoordinatesInitial()) {
    on<CoordinatesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
