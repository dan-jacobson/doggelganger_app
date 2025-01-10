import 'dart:io';
import 'dart:typed_data';
import 'package:doggelganger_app/widgets/gradient_background.dart';
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

class MatchedDogScreenState extends State<MatchedDogScreen>
    with TickerProviderStateMixin {
  bool _isUserImageExpanded = false;
  bool _isDogImageExpanded = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<String> _screenshotPaths = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          '${widget.dog.name}!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 46,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildImageSection() {                                                                                                                                                                                       
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,                                                                                                                                                             
        children: [                                                                                                                                                                                                   
          Expanded(                                                                                                                                                                                                   
            child: GestureDetector(                                                                                                                                                                                   
              onTap: () {                                                                                                                                                                                             
                setState(() {                                                                                                                                                                                         
                  _isUserImageExpanded = !_isUserImageExpanded;                                                                                                                                                       
                  _isDogImageExpanded = false;                                                                                                                                                                        
                });                                                                                                                                                                                                   
              },                                                                                                                                                                                                      
              child: AnimatedContainer(                                                                                                                                                                               
                duration: const Duration(milliseconds: 300),                                                                                                                                                          
                margin: EdgeInsets.all(8),                                                                                                                                                                            
                child: AspectRatio(                                                                                                                                                                                   
                  aspectRatio: _isUserImageExpanded ? 2/3 : 3/4,                                                                                                                                                      
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
          Expanded(                                                                                                                                                                                                   
            child: GestureDetector(                                                                                                                                                                                   
              onTap: () {                                                                                                                                                                                             
                setState(() {                                                                                                                                                                                         
                  _isDogImageExpanded = !_isDogImageExpanded;                                                                                                                                                         
                  _isUserImageExpanded = false;                                                                                                                                                                       
                });                                                                                                                                                                                                   
              },                                                                                                                                                                                                      
              child: AnimatedContainer(                                                                                                                                                                               
                duration: const Duration(milliseconds: 300),                                                                                                                                                          
                margin: EdgeInsets.all(8),                                                                                                                                                                            
                child: AspectRatio(                                                                                                                                                                                   
                  aspectRatio: _isDogImageExpanded ? 2/3 : 3/4,                                                                                                                                                       
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
        // Text(
        //   widget.dog.description,
        //   overflow: TextOverflow.fade,
        // )
      ],
      ),
    );
  }

  Widget _buildAdoptButton() {
    return ElevatedButton.icon(
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
      icon: const Icon(Icons.pets, size: 28),
      label: Text(
        'Adopt ${widget.dog.name}!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: Size(MediaQuery.of(context).size.width * .68, 60),
        padding: EdgeInsets.zero,
      ),
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
                )
              ],
              backgroundColor: Colors.transparent,
            ),
            Expanded(
                child: Column(
                  children: [
                  Expanded(flex: 10, child: _buildHeader()),
                  Expanded(flex: 60, child: _buildImageSection()),
                    Expanded(
                      flex: 20,
                      child: SingleChildScrollView(
                        child: _buildDogInfo()
                        )
                      ),
                    Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                      child: _buildAdoptButton()
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
