import 'package:flutter/material.dart';
import 'package:doggelganger_app/screens/home_screen.dart';
import 'package:doggelganger_app/config/environment.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  Environment.appFlavor = Flavor.development;
  runApp(const DoggelgangerApp());
}

class DoggelgangerApp extends StatelessWidget {
  const DoggelgangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doggelganger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 6, 230, 218)),
        textTheme: GoogleFonts.figtreeTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
