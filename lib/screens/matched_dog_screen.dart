import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;

class MatchedDogScreen extends StatefulWidget {
  final DogData dog;
  final String userImagePath;

  const MatchedDogScreen({
    Key? key,
    required this.dog,
    required this.userImagePath,
  }) : super(key: key);

  @override
  _MatchedDogScreenState createState() => _MatchedDogScreenState();
}

class _MatchedDogScreenState extends State<MatchedDogScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isUserImageExpanded = false;
  bool _isDogImageExpanded = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  List<String> _screenshotPaths = [];

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'You matched with ${widget.dog.name}!',
        style: GoogleFonts.quicksand(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isUserImageExpanded = !_isUserImageExpanded;
              _isDogImageExpanded = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isUserImageExpanded ? 250 : 150,
            height: _isUserImageExpanded ? 250 : 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(widget.userImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDogImageExpanded = !_isDogImageExpanded;
              _isUserImageExpanded = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDogImageExpanded ? 250 : 150,
            height: _isDogImageExpanded ? 250 : 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.dog.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDogInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breed: ${widget.dog.breed}',
            style: GoogleFonts.quicksand(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Age: ${widget.dog.age}',
            style: GoogleFonts.quicksand(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Gender: ${widget.dog.gender}',
            style: GoogleFonts.quicksand(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'About ${widget.dog.name}:',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.dog.description,
            style: GoogleFonts.quicksand(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          final Uri url = Uri.parse(widget.dog.adoptionUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not launch adoption URL'),
              ),
            );
          }
        },
        child: Text(
          'Adopt ${widget.dog.name}',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('My Doggelganger'),
      ),
      body: Stack(
        children: [
          Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildImageSection(),
                          _buildDogInfo(),
                        ],
                      ),
                    ),
                  ),
                  _buildAdoptButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (rest of the widget methods from MatchedDogView)
}
