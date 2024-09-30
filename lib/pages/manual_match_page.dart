import 'package:flutter/material.dart';
import '../widgets/field/field_drawing.dart';

class ManualMatchPage extends StatelessWidget {
  const ManualMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matchNameNotifier = ValueNotifier<String>('Unsaved Match');

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: matchNameNotifier,
          builder: (context, matchName, child) {
            return Text(matchName);
          },
        ),
      ),
      body: Center(
        child: FieldDrawing(
          matchNameNotifier: matchNameNotifier,
        ),
      ),
    );
  }
}

