import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'features/active_trip/provider/active_trip_provider.dart';

void main() {
  runApp(
    // Provided above MaterialApp so modal sheets share the same instance.
    ChangeNotifierProvider(
      create: (_) => ActiveTripProvider()..init(),
      child: const GtsApp(),
    ),
  );
}
