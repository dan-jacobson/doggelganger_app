import 'package:doggelganger/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:doggelganger/widgets/carousel_view.dart';
import 'package:doggelganger/widgets/bottom_button.dart';
import 'package:doggelganger/widgets/calculating_view.dart';
import 'package:doggelganger/screens/matched_dog_screen.dart';
import 'package:doggelganger/models/dog_data.dart';
import 'package:doggelganger/services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    ApiService.warmUp();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await startCalculating(image);
    }
  }

  Future<void> startCalculating(XFile image) async {
    setState(() {
      isCalculating = true;
    });
    try {
      final (matchedDogData, userEmbedding) =
          await ApiService.uploadImageAndGetMatch(image.path);
      if (!mounted) return;
      setState(() {
        isCalculating = false;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MatchedDogScreen(
            dog: matchedDogData,
            userImagePath: image.path,
            userEmbedding: userEmbedding,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

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
        body: GradientBackground(
      child: SafeArea(
        child: isCalculating
            ? const CalculatingView()
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                          height: constraints.maxHeight *
                              0.03), // 3% of screen height
                      Expanded(
                        flex: 8,
                        child: DogCarouselView(),
                      ),
                      SizedBox(
                          height: constraints.maxHeight *
                              0.03), // 3% of screen height
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: constraints.maxHeight *
                                0.03), // 3% of screen height
                        child: Center(
                          // adjust the button width dependong on the size of the screen
                          child: LayoutBuilder(
                              builder: (context, buttonConstraints) {
                            double buttonWidth;
                            if (constraints.maxWidth < 390) {
                              // if we're on a small phone
                              buttonWidth = constraints.maxWidth * 0.85;
                            } else if (constraints.maxWidth < 500) {
                              // Normal sized phones
                              buttonWidth = constraints.maxWidth * 0.8;
                            } else {
                              // Fixed size for tablets and other larger devices
                              buttonWidth = 500;
                            }

                            return SizedBox(
                              width: buttonWidth,
                              child: BottomButton(
                                onPressed: _pickImage,
                                icon: Icons.pets,
                                label: 'Find your doggelganger!',
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    ));
  }
}
