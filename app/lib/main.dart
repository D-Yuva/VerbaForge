import 'package:flutter/material.dart';
import 'ScriptGeneratorScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Script Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScriptGeneratorScreen(),
    );
  }
}
