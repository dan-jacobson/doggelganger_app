import 'package:flutter/material.dart';
import 'package:doggelganger/screens/home_screen.dart';
import 'package:doggelganger/config/environment.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  const isDev = bool.fromEnvironment('dev', defaultValue: false);

  if (isDev) {
    Environment.appFlavor = Flavor.development;
  } else {
    Environment.appFlavor = Flavor.production;
  }
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
