import 'dart:io';

import 'package:map_app/models/message.dart';
import 'package:map_app/services/coordinates_extractor_service.dart';

class CoordinateData {
  final double lat;
  final double long;
  final int quantity;
  final String name;
  final DateTime time;
  final String message;

  static final GeminiCoordinatesExtractor _extractor =
      GeminiCoordinatesExtractor(
    apiKey: '',
  );

  static final defaultLocation = (
    lat: 50.408750,
    long: 30.628861,
  );

  CoordinateData({
    required this.quantity,
    required this.lat,
    required this.long,
    required this.name,
    required this.time,
    required this.message,
  });

  static Future<List<CoordinateData>> fromMessage(Message message) async {
    final threats = await _extractor.extractThreats(message.messageText);
    final citiesData = await _loadCitiesData(); // Load CSV data

    return threats.map((threat) {
      // Find matching city data
      final cityData = citiesData.firstWhere(
        (city) => city.name.toLowerCase() == threat.$2?.toLowerCase(),
        orElse: () => CityData(
            // Default values if city not found
            name: threat.$2 ?? 'невідомо',
            lat: defaultLocation.lat,
            long: defaultLocation.long),
      );

      return CoordinateData(
        lat: cityData.lat,
        long: cityData.long,
        name: threat.$1 ?? 'невідомо', // threat type
        quantity: threat.$3 ?? 1,
        time: DateTime.now(),
        message: message.messageText,
      );
    }).toList();
  }
}

class CityData {
  final String name;
  final double lat;
  final double long;

  CityData({required this.name, required this.lat, required this.long});
}

Future<List<CityData>> _loadCitiesData() async {
  final file = File('міста_україни.csv');
  final lines = await file.readAsLines();

  return lines.skip(1).map((line) {
    final parts = line.split(',');
    return CityData(
      name: parts[0],
      lat: double.parse(parts[1]),
      long: double.parse(parts[2]),
    );
  }).toList();
}
