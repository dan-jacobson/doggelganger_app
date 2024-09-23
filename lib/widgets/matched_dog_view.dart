import 'dart:io';
import 'package:flutter/material.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchedDogView extends StatelessWidget {
  final DogData dog;
  final String userImagePath;

  const MatchedDogView({super.key, required this.dog, required this.userImagePath});

  TextStyle get _baseTextStyle => GoogleFonts.quicksand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  'Your Doggelganger is...',
                  style: _baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  dog.name,
                  style: _baseTextStyle.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildImageContainer(context, dog.imageSource, isUserImage: false, alignment: Alignment.centerRight),
                    _buildImageContainer(context, userImagePath, isUserImage: true, alignment: Alignment.centerLeft),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dog.breed,
                              style: _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Platform.isIOS
                                ? const Icon(CupertinoIcons.share)
                                : const Icon(Icons.share),
                            onPressed: () {
                              Share.share('Check out my Doggelganger, ${dog.name}!');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${dog.age} • ${dog.sex}',
                            style: _baseTextStyle.copyWith(fontSize: 16),
                          ),
                          Text(
                            dog.location,
                            style: _baseTextStyle.copyWith(fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () async {
              if (await canLaunch(dog.adoptionLink)) {
                await launch(dog.adoptionLink);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: _buildAdoptMeButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContainer(BuildContext context, String imagePath, {required bool isUserImage, required Alignment alignment}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: alignment,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
        child: isUserImage
            ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading user image: $imagePath');
                  return const Center(child: Text('Error loading image'));
                },
              )
            : Image.network(
                imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading dog image: $imagePath');
                  return const Center(child: Text('Error loading image'));
                },
              ),
      ),
    );
  }

  Widget _buildAdoptMeButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.pets, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          'Adopt Me!',
          style: _baseTextStyle.copyWith(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
