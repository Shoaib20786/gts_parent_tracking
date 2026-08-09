import 'package:flutter/material.dart';

import '../features/active_trip/presentation/screens/active_trip_screen.dart';
import 'theme/app_theme.dart';

class GtsApp extends StatelessWidget {
  const GtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ActiveTripScreen(),
    );
  }
}
