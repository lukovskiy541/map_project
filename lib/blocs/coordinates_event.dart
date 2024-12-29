part of 'coordinates_bloc.dart';

abstract class CoordinatesEvent {}

class AddCoordinate extends CoordinatesEvent {
  final Message message;

  AddCoordinate(this.message);
}

class RemoveCoordinate extends CoordinatesEvent {
  final CoordinateData coordinate;

  RemoveCoordinate(this.coordinate);
}

class ClearCoordinates extends CoordinatesEvent {}

class InitializeSocket extends CoordinatesEvent {}
class DisconnectSocket extends CoordinatesEvent {}
class UpdateCoordinates extends CoordinatesEvent {
  final List<CoordinateData> coordinates;
  
  UpdateCoordinates(this.coordinates);
  
 
}