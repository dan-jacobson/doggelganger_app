import 'package:flutter/material.dart';
import 'package:doggelganger/screens/home_screen.dart';
import 'package:doggelganger/config/environment.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  Environment.appFlavor = Flavor.development;
  runApp(const DoggelgangerApp());
}

class DoggelgangerApp extends StatelessWidget {
  const DoggelgangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Doggelganger',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 150, 21, 160)),
        textTheme: GoogleFonts.figtreeTextTheme(textTheme).copyWith(
          bodyMedium: GoogleFonts.cabin(textStyle: textTheme.bodyMedium),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
