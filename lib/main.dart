import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_app/blocs/coordinates_bloc.dart';
import 'app.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => CoordinatesBloc(),
      child: MyApp(),
    ),
  );
}
