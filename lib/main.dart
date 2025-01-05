import 'package:flutter/material.dart';
import 'package:doggelganger_app/screens/home_screen.dart';
import 'package:doggelganger_app/config/environment.dart';

void main() {
  const flavor = String.fromEnvironment('FLAVOR');
  Environment.appFlavor = flavor == 'production' ? Flavor.production : Flavor.development;
  runApp(const DoggelgangerApp());
}

class DoggelgangerApp extends StatelessWidget {
  const DoggelgangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doggelganger',
      theme: ThemeData(
        primaryColor: const Color(0xFF3399DD),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFFAB04F),
          surface: const Color(0xFFF2F2F7),
        ),
        fontFamily: 'Chalkduster',
      ),
      home: const HomeScreen(),
    );
  }
}
