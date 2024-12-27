import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final List<List<double>> coordinates;

  MapScreen({super.key, required this.coordinates});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Polygon> _polygons = [];

  @override
  void initState() {
    super.initState();
    for (var polygon in widget.coordinates) {
      _polygons.add(buildSquare(
        LatLng(
          polygon[0],
          polygon[1],
        ),
        LatLng(
          polygon[2],
          polygon[3],
        ),
      ));
    }
  }

  Polygon buildSquare(LatLng southwest, LatLng northeast) {
    return Polygon(
      points: [
        southwest, // Південно-західна точка,
        LatLng(
            southwest.latitude, northeast.longitude), // Південно-східна точка
        northeast, // Північно-східна точка
        LatLng(
            northeast.latitude, southwest.longitude), // Північно-західна точка
        southwest, // Повернення до початкової точки
      ],
      color: Colors.blue.withOpacity(0.5),
      borderColor: Colors.blue,
      borderStrokeWidth: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Координати для прикладу (центральна Україна)


    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map with Square'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(48.3794, 31.1656),
          initialZoom: 6.0,
          minZoom: 5.0,
          maxZoom: 18.0,
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(
              LatLng(44.3864, 22.1371), // Southwest
              LatLng(52.3791, 40.2074), // Northeast
            ),
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolygonLayer(
            polygons: _polygons,
          ),
        ],
      ),
    );
  }
}
