

import 'package:map_app/models/message.dart';
import 'package:map_app/services/coordinates_extractor_service.dart';
import 'package:flutter/services.dart' show rootBundle;

class CoordinateData {
  final double lat;
  final double long;
  final int quantity;
  final String name;
  final DateTime time;
  final String message;

  static final GeminiCoordinatesExtractor _extractor =
      GeminiCoordinatesExtractor(
    apiKey: 'AIzaSyBbp55D9tXMFmH8lCVuxl-I9yzbLy2hnDY',
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
    final citiesData = await _loadCitiesData();
    print("got message");
    return threats.map((threat) {
      final cityData = citiesData.firstWhere(
        (city) => city.name.toLowerCase() == threat.$2?.toLowerCase(),
        orElse: () => CityData(
            name: threat.$2 ?? 'невідомо',
            lat: defaultLocation.lat,
            long: defaultLocation.long),
      );

      return CoordinateData(
        lat: cityData.lat,
        long: cityData.long,
        name: threat.$1 ?? 'невідомо',
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
  try {
    final String content = await rootBundle.loadString('assets/міста_україни.csv');
    final List<String> lines = content.split('\n');
    
    print('Loaded ${lines.length} lines from CSV');
    
    return lines.skip(1).map((line) {
      try {
        final parts = line.trim().split(',');
        if (parts.length >= 3) {
          return CityData(
            name: parts[0].trim(),
            lat: double.parse(parts[1].trim()),
            long: double.parse(parts[2].trim()),
          );
        }
 
        return null;
      } catch (e) {
        print('Error parsing line: $line');
        print('Error: $e');
        return null;
      }
    })
    .where((city) => city != null)
    .cast<CityData>()
    .toList();
  } catch (e) {
    print('Error loading cities data: $e');
    return [
      
    ];
  }
}
