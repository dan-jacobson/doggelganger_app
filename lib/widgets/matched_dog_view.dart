import 'dart:io';
import 'package:flutter/material.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchedDogView extends StatefulWidget {
  final DogData dog;
  final String userImagePath;

  const MatchedDogView({super.key, required this.dog, required this.userImagePath});

  @override
  _MatchedDogViewState createState() => _MatchedDogViewState();
}

class _MatchedDogViewState extends State<MatchedDogView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isUserImageExpanded = false;
  bool _isDogImageExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleImageExpansion(bool isUserImage) {
    setState(() {
      if (isUserImage) {
        _isUserImageExpanded = !_isUserImageExpanded;
        _isDogImageExpanded = false;
      } else {
        _isDogImageExpanded = !_isDogImageExpanded;
        _isUserImageExpanded = false;
      }
    });
    if (_isUserImageExpanded || _isDogImageExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

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
                  widget.dog.name,
                  style: _baseTextStyle.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            top: 20 + _animation.value * ((_isDogImageExpanded ? -20 : 0)),
                            left: 20 + _animation.value * ((_isDogImageExpanded ? -20 : 0)),
                            right: 20 + _animation.value * ((_isDogImageExpanded ? -20 : MediaQuery.of(context).size.width * 0.45 - 20)),
                            bottom: 20 + _animation.value * ((_isDogImageExpanded ? -20 : MediaQuery.of(context).size.height * 0.25 - 20)),
                            child: GestureDetector(
                              onTap: () => _toggleImageExpansion(false),
                              child: _buildImageContainer(
                                context,
                                widget.dog.imageSource,
                                isUserImage: false,
                                isExpanded: _isDogImageExpanded,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20 + _animation.value * ((_isUserImageExpanded ? -20 : MediaQuery.of(context).size.height * 0.25 - 20)),
                            left: 20 + _animation.value * ((_isUserImageExpanded ? -20 : MediaQuery.of(context).size.width * 0.45 - 20)),
                            right: 20 + _animation.value * ((_isUserImageExpanded ? -20 : 0)),
                            bottom: 20 + _animation.value * ((_isUserImageExpanded ? -20 : 0)),
                            child: GestureDetector(
                              onTap: () => _toggleImageExpansion(true),
                              child: _buildImageContainer(
                                context,
                                widget.userImagePath,
                                isUserImage: true,
                                isExpanded: _isUserImageExpanded,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
                              widget.dog.breed,
                              style: _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Platform.isIOS
                                ? const Icon(CupertinoIcons.share)
                                : const Icon(Icons.share),
                            onPressed: () {
                              Share.share('Check out my Doggelganger, ${widget.dog.name}!');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.dog.age} • ${widget.dog.sex}',
                            style: _baseTextStyle.copyWith(fontSize: 16),
                          ),
                          Text(
                            widget.dog.location,
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
              if (await canLaunch(widget.dog.adoptionLink)) {
                await launch(widget.dog.adoptionLink);
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

  Widget _buildImageContainer(BuildContext context, String imagePath, {required bool isUserImage, required bool isExpanded}) {
    final double containerSize = MediaQuery.of(context).size.width * 0.45 + _animation.value * (MediaQuery.of(context).size.width * 0.55);

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 - _animation.value * 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2 + _animation.value * 3,
            blurRadius: 3 + _animation.value * 4,
            offset: Offset(0, 1 + _animation.value * 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20 - _animation.value * 10),
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
