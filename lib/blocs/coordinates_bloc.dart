import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_app/models/coordinate.dart';
import 'package:map_app/models/message.dart';
import 'package:map_app/services/socket_service.dart';


part 'coordinates_event.dart';
part 'coordinates_state.dart';



class CoordinatesBloc extends Bloc<CoordinatesEvent, CoordinatesState> {
  final int _maxCoordinates = 200;
  final _coordinates = <CoordinateData>[];
  final SocketService _socketService;

  CoordinatesBloc({SocketService? socketService}) 
      : _socketService = socketService ?? SocketService(),
        super(CoordinatesInitial()) {
    on<AddCoordinate>(_onAddCoordinate);
    on<RemoveCoordinate>(_onRemoveCoordinate);
    on<ClearCoordinates>(_onClearCoordinates);
    on<InitializeSocket>(_onInitializeSocket);
    on<DisconnectSocket>(_onDisconnectSocket);
    on<UpdateCoordinates>((event, emit) {
      emit(CoordinatesLoaded(event.coordinates));
    });
    add(InitializeSocket());
  }

  void _onInitializeSocket(InitializeSocket event, Emitter<CoordinatesState> emit) {
  print('Initializing socket connection...');
  _socketService.connect();
  _socketService.onNewMessage((message) {
    print('Received message in bloc: ${message.toString()}');
    add(AddCoordinate(message));
  });
}

  void _onDisconnectSocket(DisconnectSocket event, Emitter<CoordinatesState> emit) {
    _socketService.disconnect();
  }

  void _onAddCoordinate(AddCoordinate event, Emitter<CoordinatesState> emit) async {
    try {
      final newCoordinates = await CoordinateData.fromMessage(event.message);
      
      for (final coordinate in newCoordinates) {
        if (_coordinates.length >= _maxCoordinates) {
          _coordinates.removeLast();
        }
        _coordinates.insert(0, coordinate);
      }
      
      emit(CoordinatesLoaded(List.from(_coordinates)));
    } catch (e) {
      emit(CoordinatesError('Failed to parse coordinates: $e'));
      emit(CoordinatesLoaded(List.from(_coordinates))); 
    }
  }

  void _onRemoveCoordinate(RemoveCoordinate event, Emitter<CoordinatesState> emit) {
    _coordinates.remove(event.coordinate);
    emit(CoordinatesLoaded(List.from(_coordinates)));
  }

  void _onClearCoordinates(ClearCoordinates event, Emitter<CoordinatesState> emit) {
    _coordinates.clear();
    emit(CoordinatesLoaded([]));
  }

  @override
  Future<void> close() {
    _socketService.disconnect();
    return super.close();
  }
}