import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/blocs/coordinates_bloc.dart';
import 'package:map_app/models/coordinate.dart';

class MapScreen extends StatefulWidget {
  final List<CoordinateData> coordinates;

  const MapScreen({super.key, required this.coordinates});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Timer? _cleanupTimer;

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _removeOldMarkers();
    });
  }

  void _removeOldMarkers() {
    final coordinatesBloc = context.read<CoordinatesBloc>();
    if (coordinatesBloc.state is CoordinatesLoaded) {
      final currentTime = DateTime.now();
      final state = coordinatesBloc.state as CoordinatesLoaded;

      final updatedCoordinates = state.coordinates.where((coord) {
        final difference = currentTime.difference(coord.time);
        return difference.inMinutes < 5;
      }).toList();

      if (updatedCoordinates.length != state.coordinates.length) {
        coordinatesBloc.add(UpdateCoordinates(updatedCoordinates));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoordinatesBloc, CoordinatesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Map with Square'),
          ),
          body: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(48.3794, 31.1656),
              initialZoom: 6.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                scrollWheelVelocity: 0.01,
                enableMultiFingerGestureRace: true,
                flags: InteractiveFlag.all,
              ),
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  LatLng(44.3864, 22.1371),
                  LatLng(52.3791, 40.2074),
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: state is CoordinatesLoaded
                    ? state.coordinates.map((coord) {
                        double width =30.0;
                        double height = 30.0;
                        Widget icon = Image.asset('assets/uav.png',
                            fit: BoxFit.contain);

                        if (coord.name == "ракета") {
                          icon = Image.asset('assets/missile.png',
                              fit: BoxFit.contain);
                        }
                        if (coord.name == "балістика") {
                          width = 60.0;
                          height = 60.0;
                          icon = Image.asset('assets/iskander.png',
                              fit: BoxFit.contain);
                        }
                        if (coord.name == "калібр") {
                          width = 60.0;
                          height = 60.0;
                          icon = Image.asset('assets/kalibr.png',
                              fit: BoxFit.contain);
                        }

                        return Marker(
                          point: LatLng(coord.lat, coord.long),
                          width: width,
                          height: height,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Location Details'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Latitude: ${coord.lat}'),
                                      Text('Longitude: ${coord.long}'),
                                      Text('Name: ${coord.name}'),
                                      Text('Time: ${coord.time}'),
                                      Text('Message: ${coord.message}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                icon,
                                if (coord.quantity >
                                    1) // показуємо badge тільки якщо є загрози
                                  Positioned(
                                    right: -5,
                                    top: -5,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 15,
                                        minHeight: 15,
                                      ),
                                      child: Text(
                                        '${coord.quantity}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    : [],
              ),
            ],
          ),
        );
      },
    );
  }

  Polygon<Object> buildSquare(LatLng southwest, LatLng northeast) {
    return Polygon(
      points: [
        southwest,
        LatLng(southwest.latitude, northeast.longitude),
        northeast,
        LatLng(northeast.latitude, southwest.longitude),
        southwest,
      ],
      color: Colors.red.withOpacity(0.5),
      borderColor: Colors.red,
      borderStrokeWidth: 2.0,
    );
  }
}
