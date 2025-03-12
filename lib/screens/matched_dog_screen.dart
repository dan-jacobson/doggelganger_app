import 'dart:io';
import 'dart:typed_data';
import 'package:doggelganger/widgets/gradient_background.dart';
import 'package:doggelganger/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:doggelganger/models/dog_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;
import 'package:auto_size_text/auto_size_text.dart';

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

class MatchedDogScreenState extends State<MatchedDogScreen>
    with TickerProviderStateMixin {
  bool _isUserImageExpanded = false;
  bool _isDogImageExpanded = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<String> _screenshotPaths = [];
  final GlobalKey headerKey = GlobalKey();
  final GlobalKey dogInfoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cleanupAllScreenshots();
    super.dispose();
  }

  double? getWidgetYPosition(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    return renderBox.localToGlobal(Offset.zero).dy;
  }

  Future<void> _shareScreenshot() async {
    final imagePath = await _captureAndSaveScreenshot();
    _screenshotPaths.add(imagePath);
    await Share.shareXFiles(
      [XFile(imagePath, mimeType: "image/png")],
      subject: 'Check out my Doggelganger',
    );

    // Cleanup old screenshots if there are more than 5
    if (_screenshotPaths.length > 5) {
      await _cleanupOldScreenshots();
    }
  }

  Future<String> _captureAndSaveScreenshot() async {
    final pixelRatio = 3.0;

    final Uint8List? imageBytes = await _screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: pixelRatio,
    );

    if (imageBytes == null) {
      throw Exception('Failed to capture screenshot');
    }

    // Get the pixel positions of the tops of header and dogInfo widgets
    // That defines the bounds we want to screenshot
    final headerY = getWidgetYPosition(headerKey);
    final dogInfoY = getWidgetYPosition(dogInfoKey);

    if (headerY == null || dogInfoY == null) {
      throw Exception("Failed to get widget Y positions");
    }

    // Decode the image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate crop dimensions
    final int topCrop = (headerY * pixelRatio).round();
    final int bottomCrop = ((dogInfoY + 8) * pixelRatio)
        .round(); // TODO(drj): get padding (8) programmatically

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
        AutoSizeText(
          '${widget.dog.name}!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).secondaryHeaderColor,
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          minFontSize: 20,
          maxFontSize: 36,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      final double maxHeight = constraints.maxHeight;

      Widget userImage = Positioned(
          key: ValueKey('user'),
          left: _isUserImageExpanded
              ? (maxWidth * 0.1)
              : (_isDogImageExpanded ? maxWidth * 0.08 : 20),
          top: _isUserImageExpanded
              ? 5
              : (_isDogImageExpanded ? maxHeight * .6 : 30),
          width: _isUserImageExpanded
              ? maxWidth * 0.67
              : (_isDogImageExpanded ? maxWidth * 0.25 : maxWidth * 0.45),
          height: _isUserImageExpanded
              ? maxHeight * 0.95
              : (_isDogImageExpanded ? maxHeight * 0.38 : maxHeight * 0.7),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isUserImageExpanded = !_isUserImageExpanded;
                _isDogImageExpanded = false;
              });
            },
            child: Transform.rotate(
              angle: -0.052,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(_isDogImageExpanded ? 5 : 10),
                child: Image.file(
                  File(widget.userImagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ));

      Widget dogImage = Positioned(
          key: ValueKey('dog'),
          right: _isDogImageExpanded
              ? (maxWidth * 0.1)
              : (_isUserImageExpanded ? maxWidth * 0.08 : 20),
          bottom: _isDogImageExpanded
              ? 12
              : (_isUserImageExpanded ? maxHeight * 0.1 : 30),
          width: _isDogImageExpanded
              ? maxWidth * 0.67
              : (_isUserImageExpanded ? maxWidth * 0.25 : maxWidth * 0.45),
          height: _isDogImageExpanded
              ? maxHeight * 0.95
              : (_isUserImageExpanded ? maxHeight * 0.38 : maxHeight * 0.7),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isDogImageExpanded = !_isDogImageExpanded;
                _isUserImageExpanded = false;
              });
            },
            child: Transform.rotate(
              angle: 0.052,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(_isUserImageExpanded ? 5 : 10),
                child: Image.network(
                  widget.dog.photo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ));

      return AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Stack(
            key: ValueKey('${_isUserImageExpanded}_$_isDogImageExpanded'),
            children: _isDogImageExpanded
                ? [dogImage, userImage]
                : [userImage, dogImage],
          ));
    });
  }

  Widget _buildDogInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      foregroundDecoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((255 * 0.5).round()),
              ),
              child: Column(children: [
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
              ])),
          Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                widget.dog.description,
                overflow: TextOverflow.fade,
              ))
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
          if (!mounted) return;
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
                        : const Icon(Icons.share)),
              ],
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(flex: 5, key: headerKey, child: (_buildHeader())),
                  Expanded(flex: 20, child: _buildImageSection()),
                  Expanded(
                    flex: 15,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          key: dogInfoKey,
                          child: Padding(
                              padding: EdgeInsets.only(bottom: 110),
                              child: _buildDogInfo()),
                        ),
                        Positioned(
                            bottom: MediaQuery.of(context).size.height * 0.06,
                            left: MediaQuery.of(context).size.width * 0.06,
                            right: MediaQuery.of(context).size.width * 0.06,
                            child: _buildAdoptButton())
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
