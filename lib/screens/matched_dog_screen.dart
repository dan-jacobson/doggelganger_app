import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
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
  
  Future<void> _shareScreenshot() async {
    final imagePath = await _captureAndSaveScreenshot();
    _screenshotPaths.add(imagePath);
    await Share.shareXFiles(
      [XFile(imagePath, mimeType: "image/png")],
      // text: 'Check out my Doggelganger, ${widget.dog.name}!',
      subject: 'Check out my Doggelganger',
    );

    // Cleanup old screenshots if there are more than 5
    if (_screenshotPaths.length > 5) {
      await _cleanupOldScreenshots();
    }
  }

  Future<String> _captureAndSaveScreenshot() async {
    final Uint8List? imageBytes = await _screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    );

    if (imageBytes == null) {
      throw Exception('Failed to capture screenshot');
    }

    // Decode the image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate crop dimensions
    final int bottomCrop = (image.height * 0.83).round(); // Cut out the bottom

    // Crop the image
    final croppedImage = img.copyCrop(
      image,
      x: 0,
      y: 0,
      width: image.width,
      height: bottomCrop,
    );

    // Encode the cropped image
    final croppedImageBytes = img.encodePng(croppedImage);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file =
        await File('${tempDir.path}/doggelganger_$timestamp.png').create();
    file.writeAsBytesSync(croppedImageBytes);

    return file.path;
  }

  Future<void> _cleanupOldScreenshots() async {
    while (_screenshotPaths.length > 5) {
      final oldPath = _screenshotPaths.removeAt(0);
      final file = File(oldPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _cleanupAllScreenshots() async {
    for (final path in _screenshotPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        Logger().e('Error deleting file: $path', error: e);
      }
    }
    _screenshotPaths.clear();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '${widget.dog.name}!',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
            height: _isUserImageExpanded ? 350 : 250,
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
            duration: const Duration(milliseconds: 100),
            width: _isDogImageExpanded ? 250 : 150,
            height: _isDogImageExpanded ? 250 : 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.dog.photo,
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
            'About ${widget.dog.name}:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Text(
            'Breed: ${widget.dog.breed}',
            style: Theme.of(context).textTheme.bodySmall
          ),
          const SizedBox(height: 8),
          Text(
            'Age: ${widget.dog.age}',
            style: Theme.of(context).textTheme.bodySmall
          ),
          const SizedBox(height: 8),
          Text(
            'Gender: ${widget.dog.sex}',
            style: Theme.of(context).textTheme.bodySmall
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAdoptButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          final Uri url = Uri.parse(widget.dog.url);
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
        title: Text('My Doggelganger is'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              FractionallySizedBox(
                heightFactor: 0.15,
                child: _buildHeader(),
              ),
              FractionallySizedBox(
                heightFactor: 0.40,
                child: _buildImageSection(),
              ),
              Expanded(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child:
                        FractionallySizedBox(
                          heightFactor: 0.30,
                          child: _buildDogInfo(),
                        ),
                    ),
                    FractionallySizedBox(
                      heightFactor: 0.15,
                      child: _buildAdoptButton(),
                    )
                  ],
                )
              )
            ],
          );
        } 
      )
      // body: Stack(
      //   children: [
      //     Screenshot(
      //       controller: _screenshotController,
      //       child: Container(
      //         child: Column(
      //           children: [
      //             Expanded(
      //               child: SingleChildScrollView(
      //                 child: Column(
      //                   children: [
      //                     _buildHeader(),
      //                     _buildImageSection(),
      //                     _buildDogInfo(),
      //                     _buildAdoptButton(),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  // ... (rest of the widget methods from MatchedDogView)
}
