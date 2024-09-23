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
  final VoidCallback onClose;

  const MatchedDogView({
    super.key,
    required this.dog,
    required this.userImagePath,
    required this.onClose,
  });

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
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // ... rest of the column content
                  ],
                ),
              ),
            ),
            // ... rest of the column content
          ],
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            color: Theme.of(context).primaryColor,
          ),
        ),
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
                      List<Widget> stackChildren = [];

                      // Add the non-expanded image first (it will be in the background)
                      if (!_isDogImageExpanded && !_isUserImageExpanded) {
                        // Both images are small, place them side-by-side
                        stackChildren.add(
                          Positioned(
                            top: 20,
                            left: 20,
                            right: MediaQuery.of(context).size.width * 0.5 + 10,
                            bottom: 20,
                            child: GestureDetector(
                              onTap: () => _toggleImageExpansion(false),
                              child: _buildImageContainer(
                                context,
                                widget.dog.imageSource,
                                isUserImage: false,
                                isExpanded: false,
                              ),
                            ),
                          ),
                        );
                        stackChildren.add(
                          Positioned(
                            top: 20,
                            left: MediaQuery.of(context).size.width * 0.5 + 10,
                            right: 20,
                            bottom: 20,
                            child: GestureDetector(
                              onTap: () => _toggleImageExpansion(true),
                              child: _buildImageContainer(
                                context,
                                widget.userImagePath,
                                isUserImage: true,
                                isExpanded: false,
                              ),
                            ),
                          ),
                        );
                      } else if (!_isDogImageExpanded) {
                        // Only dog image is small
                        stackChildren.add(
                          Positioned(
                            top: 20,
                            left: 20,
                            right: MediaQuery.of(context).size.width * 0.5,
                            bottom: MediaQuery.of(context).size.height * 0.25,
                            child: GestureDetector(
                              onTap: () => _toggleImageExpansion(false),
                              child: _buildImageContainer(
                                context,
                                widget.dog.imageSource,
                                isUserImage: false,
                                isExpanded: false,
                              ),
                            ),
                          ),
                        );
                      } else if (!_isUserImageExpanded) {
                        // Only user image is small
                        stackChildren.add(
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.25,
                            left: MediaQuery.of(context).size.width * 0.5,
                            right: 20,
                            bottom: 20,
                            child: GestureDetector(
                              onTap: () => _toggleImageExpansion(true),
                              child: _buildImageContainer(
                                context,
                                widget.userImagePath,
                                isUserImage: true,
                                isExpanded: false,
                              ),
                            ),
                          ),
                        );
                      }

                      // Add the expanded image last (it will be on top)
                      if (_isDogImageExpanded) {
                        stackChildren.add(
                          Positioned.fill(
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
                        );
                      }

                      if (_isUserImageExpanded) {
                        stackChildren.add(
                          Positioned.fill(
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
                        );
                      }

                      return Stack(children: stackChildren);
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
    final double containerSize = isExpanded
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width * 0.45;
    final double borderRadius = isExpanded ? 0 : 20;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: isExpanded ? 5 : 2,
            blurRadius: isExpanded ? 7 : 3,
            offset: isExpanded ? const Offset(0, 3) : const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
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
