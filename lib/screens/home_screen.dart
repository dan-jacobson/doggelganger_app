import 'package:flutter/material.dart';
import 'package:doggelganger_app/widgets/carousel_view.dart';
import 'package:doggelganger_app/widgets/image_picker_button.dart';
import 'package:doggelganger_app/widgets/calculating_view.dart';
import 'package:doggelganger_app/widgets/matched_dog_view.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DogData> dogs = [];
  bool isCalculating = false;
  DogData? matchedDog;

  @override
  void initState() {
    super.initState();
    loadDogData();
  }

  Future<void> loadDogData() async {
    final String response = await rootBundle.loadString('assets/dog_metadata.json');
    final List<dynamic> data = await json.decode(response);
    setState(() {
      dogs = data.map((json) => DogData.fromJson(json)).toList();
    });
  }

  void startCalculating() {
    setState(() {
      isCalculating = true;
    });
    // Simulate API call
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isCalculating = false;
        matchedDog = dogs[DateTime.now().millisecond % dogs.length];
      });
    });
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
              : matchedDog != null
                  ? MatchedDogView(dog: matchedDog!)
                  : Column(
                      children: [
                        Expanded(
                          child: CarouselView(dogs: dogs),
                        ),
                        ImagePickerButton(
                          onImageSelected: (image) {
                            if (image != null) {
                              startCalculating();
                            }
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
