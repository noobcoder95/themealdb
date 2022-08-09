import 'package:flutter/material.dart';
import 'package:themealdb/ui/home_screen.dart';

void main() => runApp(MyApplication());

class MyApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TheMealDB',
        debugShowCheckedModeBanner: false,
        home: HomeScreen());
  }
}