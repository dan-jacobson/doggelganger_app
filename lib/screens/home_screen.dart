import 'package:doggelganger_app/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:doggelganger_app/widgets/carousel_view.dart';
import 'package:doggelganger_app/widgets/bottom_button.dart';
import 'package:doggelganger_app/widgets/calculating_view.dart';
import 'package:doggelganger_app/screens/matched_dog_screen.dart';
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
      final matchedDogData =
          await ApiService.uploadImageAndGetMatch(image.path);
      setState(() {
        isCalculating = false;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MatchedDogScreen(
            dog: matchedDogData,
            userImagePath: image.path,
          ),
        ),
      );
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
      body: GradientBackground(
        child: SafeArea(
              child: isCalculating
                  ? const CalculatingView()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
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
                              child: BottomButton(
                                onPressed: _pickImage,
                                icon: Icons.pets,
                                label: 'Find your doggelganger!',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          )
      );
  }
}
