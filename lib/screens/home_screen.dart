import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doggelganger_app/widgets/carousel_view.dart';
import 'package:doggelganger_app/widgets/image_picker_button.dart';
import 'package:doggelganger_app/widgets/calculating_view.dart';
import 'package:doggelganger_app/widgets/matched_dog_view.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:doggelganger_app/services/api_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextStyle get _baseTextStyle => GoogleFonts.quicksand();
  List<DogData> dogs = [];
  bool isCalculating = false;
  DogData? matchedDog;
  String? userImagePath;

  @override
  void initState() {
    super.initState();
    loadDogData();
  }

  Future<void> loadDogData() async {
    try {
      final String response = await rootBundle.loadString('assets/images/carousel/dog_metadata.json');
      final List<dynamic> data = await json.decode(response);
      setState(() {
        dogs = data.map((json) => DogData.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading dog data: $e');
      // Handle the error, maybe show a message to the user
    }
  }

  Future<void> startCalculating(XFile image) async {
    setState(() {
      isCalculating = true;
      userImagePath = image.path;
    });
    try {
      final matchedDogData = await ApiService.uploadImageAndGetMatch(image.path);
      setState(() {
        isCalculating = false;
        matchedDog = matchedDogData;
      });
    } catch (e) {
      setState(() {
        isCalculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F3FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: isCalculating
              ? const CalculatingView()
              : matchedDog != null && userImagePath != null
                  ? MatchedDogView(dog: matchedDog!, userImagePath: userImagePath!)
                  : Column(
                      children: [
                        Expanded(
                          child: dogs.isEmpty
                              ? Center(child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                ))
                              : DogCarouselView(dogs: dogs),
                        ),
                        ImagePickerButton(
                          onImageSelected: (image) {
                            if (image != null) {
                              startCalculating(image);
                            }
                          },
                          icon: Icons.pets,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
