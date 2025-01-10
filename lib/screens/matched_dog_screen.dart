import 'dart:io';
import 'dart:typed_data';
import 'package:doggelganger_app/widgets/gradient_background.dart';
import 'package:doggelganger_app/widgets/bottom_button.dart';
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
    super.key,
    required this.dog,
    required this.userImagePath,
  });

  @override
  MatchedDogScreenState createState() => MatchedDogScreenState();
}

class DebugDivider extends StatelessWidget {
  final Color color;

  const DebugDivider({Key? key, this.color = Colors.purple}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: color,
    );
  }
}

class MatchedDogScreenState extends State<MatchedDogScreen>
    with TickerProviderStateMixin {
  bool _isUserImageExpanded = false;
  bool _isDogImageExpanded = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<String> _screenshotPaths = [];
  bool _debugMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cleanupAllScreenshots();
    super.dispose();
  }

  void _toggleDebugMode() {
    setState(() {
      _debugMode = !_debugMode;
    });
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
    final int topCrop = (image.height * .14).round();
    final int bottomCrop = (image.height * 0.83).round(); // Cut out the bottom

    // Crop the image
    final croppedImage = img.copyCrop(
      image,
      x: 0,
      y: topCrop,
      width: image.width,
      height: bottomCrop - topCrop,
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
    return Column(                                                                                                                                                                                                  
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text( 
          'My Doggelganger is...', 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8), 
        Text(
          '${widget.dog.name}!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 36
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: -10,
          child: Transform.rotate(
            angle: -0.05, // Approximately 3 degrees to the left
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isUserImageExpanded = !_isUserImageExpanded;
                  _isDogImageExpanded = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.width * (_isUserImageExpanded ? 0.6 : 0.55),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(widget.userImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: -10,
          child: Transform.rotate(
            angle: 0.05, // Approximately 3 degrees to the right
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDogImageExpanded = !_isDogImageExpanded;
                  _isUserImageExpanded = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.width * (_isDogImageExpanded ? 0.6 : 0.55),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.dog.photo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDogInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      foregroundDecoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.dog.breed,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.fade,
                ),
              ),
              Text(
                '${widget.dog.location.city}, ${widget.dog.location.state}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.right,
              )
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.dog.age} • ${widget.dog.sex}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        Text(
          widget.dog.description,
          overflow: TextOverflow.fade,
        )
      ],
      ),
    );
  }

  Widget _buildAdoptButton() {
    return BottomButton(
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
      icon: Icons.pets,
      label: 'Adopt ${widget.dog.name}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Screenshot(
        controller: _screenshotController,
        child: GradientBackground(
        child: Column(
          children: [
            AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  onPressed: _shareScreenshot,
                  icon: Platform.isIOS
                      ? const Icon(CupertinoIcons.share)
                      : const Icon(Icons.share)
                ),
                IconButton(onPressed: _toggleDebugMode, icon: Icon(Icons.bug_report))
              ],
              backgroundColor: Colors.transparent,
            ),
            if (_debugMode) DebugDivider(),
            Expanded(
                child: Column(
                  children: [
                  Expanded(flex: 10, child: _buildHeader()),
                  if (_debugMode) DebugDivider(),
                  Expanded(flex: 30, child: _buildImageSection()),
                  if (_debugMode) DebugDivider(),
                  Expanded(
                    flex: 20,
                    child: SingleChildScrollView(
                      child: _buildDogInfo()
                      )
                    ),
                  if (_debugMode) DebugDivider(),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.03,
                      left: MediaQuery.of(context).size.width * 0.03,
                      right: MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: _buildAdoptButton(),
                  ),
                  ],
                ),
              ),
          ],
        ),
      ),
      )
    );
  }
}
