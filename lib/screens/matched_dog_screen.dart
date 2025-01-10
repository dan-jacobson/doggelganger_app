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
    _cleanupAllScreenshots();
    super.dispose();
  }

  // ... (rest of the methods from MatchedDogView)

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
