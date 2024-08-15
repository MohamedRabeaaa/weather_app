import 'package:flutter/material.dart';
import 'lazy_loading_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF05406B),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LazyLoadingGrid(),
          ),
        ),
      ),
    );
  }
}
