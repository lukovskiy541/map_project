import 'package:flutter/material.dart';
import 'package:map_app/models/coordinate.dart';
import 'package:map_app/screens/map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<CoordinateData> coordinates = [];

    return MaterialApp(
      title: 'Real-Time Messages',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MapScreen(coordinates: coordinates),
    );
  }
}
