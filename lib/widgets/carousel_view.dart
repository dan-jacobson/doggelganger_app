import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DogCarouselView extends StatelessWidget {
  TextStyle get _baseTextStyle => GoogleFonts.quicksand();
  final List<DogData> dogs;

  const DogCarouselView({super.key, required this.dogs});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height:
            MediaQuery.of(context).size.height * 0.7, // 70% of screen height
        aspectRatio: 3 / 4, // More vertical aspect ratio
        viewportFraction: 0.85, // Slightly larger cards
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        enlargeFactor:
            0.3, // Increase the size difference between center and side items
      ),
      items: dogs.map((dog) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/carousel/${dog.photo}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: ${dog.photo}');
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dog.name,
                          style: _baseTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${dog.age} • ${dog.sex} • ${dog.breed}',
                          style: _baseTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${dog.location.city}, ${dog.location.state}',
                          style: _baseTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        if (dog.location.postcode != null)
                          Text(
                            'Postcode: ${dog.location.postcode}',
                            style: _baseTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
