import 'package:flutter/material.dart';
import 'package:doggelganger_app/widgets/carousel_view.dart';
import 'package:doggelganger_app/widgets/image_picker_button.dart';
import 'package:doggelganger_app/widgets/calculating_view.dart';
import 'package:doggelganger_app/widgets/matched_dog_view.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:doggelganger_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isCalculating = false;
  DogData? matchedDog;
  String? userImagePath;

  Future<void> startCalculating(XFile image) async {
    setState(() {
      isCalculating = true;
      userImagePath = image.path;
    });
    try {
      final matchedDogData =
          await ApiService.uploadImageAndGetMatch(image.path);
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
                  ? MatchedDogView(
                      dog: matchedDog!,
                      userImagePath: userImagePath!,
                      onClose: () {
                        setState(() {
                          matchedDog = null;
                          userImagePath = null;
                        });
                      },
                    )
                  : Column(
                      children: [
                        Expanded(
                          flex:
                              9, // This will make the carousel take up 90% of the available space
                          child: Transform.rotate(
                            angle:
                                0.052, // This is approximately 3 degrees in radians
                            child: DogCarouselView(),
                          ),
                        ),
                        const SizedBox(
                            height:
                                20), // Add some space between the carousel and the button
                        ImagePickerButton(
                          onImageSelected: (image) {
                            startCalculating(image);
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
