import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FRC Strategy Whiteboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: SeedColorScheme.fromSeeds(
          primaryKey: const Color(0xFF6750A4),
          brightness: Brightness.dark,
          tones: FlexTones.material3Legacy(Brightness.dark),
        ),
      ),
      home: const HomePage(),
    );
  }
}
