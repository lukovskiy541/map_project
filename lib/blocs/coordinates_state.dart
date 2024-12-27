part of 'coordinates_bloc.dart';

@immutable
abstract class CoordinatesState {}

class CoordinatesInitial extends CoordinatesState {

  final List<Coordinates> coordinates;

  CoordinatesInitial({required this.coordinates});



}
