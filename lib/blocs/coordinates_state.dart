part of 'coordinates_bloc.dart';

abstract class CoordinatesState {
  final List<CoordinateData> coordinates;
  
  CoordinatesState(this.coordinates);
}

class CoordinatesInitial extends CoordinatesState {
  CoordinatesInitial() : super([]);
}

class CoordinatesLoaded extends CoordinatesState {
  CoordinatesLoaded(super.coordinates);
}

class CoordinatesError extends CoordinatesState {
  final String error;

  CoordinatesError(this.error) : super([]);
}
