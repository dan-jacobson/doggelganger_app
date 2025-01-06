import 'dart:io';
import 'dart:ui' as ui;
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
  State<MatchedDogView> createState() => _MatchedDogViewState();
}

class _MatchedDogViewState extends State<MatchedDogView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isUserImageExpanded = false;
  bool _isDogImageExpanded = false;
  final ScreenshotController _screenshotController = ScreenshotController();

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

  Future<String> _captureAndSaveScreenshot() async {
    final Uint8List? imageBytes = await _screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    );

    if (imageBytes == null) {
      throw Exception('Failed to capture screenshot');
    }

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/doggelganger.png').create();
    await file.writeAsBytes(imageBytes);

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'My Doggelganger is...',
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
      ],
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => _buildImageStack(),
      ),
    );
  }

  Widget _buildDogInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDogInfoHeader(),
          const SizedBox(height: 10),
          _buildDogInfoDetails(),
        ],
      ),
    );
  }

  Widget _buildAdoptButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _launchAdoptionLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        child: _buildAdoptMeButton(),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 10,
      left: 10,
      child: IconButton(
        icon: const Icon(Icons.close),
        onPressed: widget.onClose,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context, String imagePath,
      {required bool isUserImage, required bool isExpanded}) {
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
                  Logger().e('Error loading user image: $imagePath');
                  return const Center(child: Text('Error loading image'));
                },
              )
            : Image.network(
                imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  Logger().e('Error loading dog image: $imagePath');
                  return const Center(child: Text('Error loading image'));
                },
              ),
      ),
    );
  }

  String _getDogImagePath(bool isExpanded) {
    return isExpanded ? widget.dog.photo : widget.dog.croppedPhoto;
  }

  Widget _buildAdoptMeButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.pets, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          'Adopt Me!',
          style: _baseTextStyle.copyWith(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  Widget _buildImageStack() {
    List<Widget> stackChildren = [];

    if (!_isDogImageExpanded && !_isUserImageExpanded) {
      stackChildren.addAll(_buildSideBySideImages());
    } else if (!_isDogImageExpanded) {
      stackChildren.add(_buildSmallDogImage());
    } else if (!_isUserImageExpanded) {
      stackChildren.add(_buildSmallUserImage());
    }

    if (_isDogImageExpanded) {
      stackChildren.add(_buildExpandedDogImage());
    }

    if (_isUserImageExpanded) {
      stackChildren.add(_buildExpandedUserImage());
    }

    return Stack(children: stackChildren);
  }

  List<Widget> _buildSideBySideImages() {
    return [
      Positioned(
        top: 20,
        left: 20,
        right: MediaQuery.of(context).size.width * 0.5 + 10,
        bottom: 20,
        child: GestureDetector(
          onTap: () => _toggleImageExpansion(false),
          child: _buildImageContainer(
            context,
            _getDogImagePath(false),
            isUserImage: false,
            isExpanded: false,
          ),
        ),
      ),
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
    ];
  }

  Widget _buildSmallDogImage() {
    return Positioned(
      top: 20,
      left: 20,
      right: MediaQuery.of(context).size.width * 0.5,
      bottom: MediaQuery.of(context).size.height * 0.25,
      child: GestureDetector(
        onTap: () => _toggleImageExpansion(false),
        child: _buildImageContainer(
          context,
          _getDogImagePath(false),
          isUserImage: false,
          isExpanded: false,
        ),
      ),
    );
  }

  Widget _buildSmallUserImage() {
    return Positioned(
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
    );
  }

  Widget _buildExpandedDogImage() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => _toggleImageExpansion(false),
        child: _buildImageContainer(
          context,
          _getDogImagePath(true),
          isUserImage: false,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildExpandedUserImage() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => _toggleImageExpansion(true),
        child: _buildImageContainer(
          context,
          widget.userImagePath,
          isUserImage: true,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildDogInfoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.dog.breed,
            style: _baseTextStyle.copyWith(
                fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Platform.isIOS
              ? const Icon(CupertinoIcons.share)
              : const Icon(Icons.share),
          onPressed: _shareScreenshot,
        ),
      ],
    );
  }

  Widget _buildDogInfoDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.dog.age} • ${widget.dog.sex}',
          style: _baseTextStyle.copyWith(fontSize: 16),
        ),
        Text(
          '${widget.dog.location.city}, ${widget.dog.location.state}',
          style: _baseTextStyle.copyWith(fontSize: 16),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Future<void> _shareScreenshot() async {
    final imagePath = await _captureAndSaveScreenshot();
    final result = await Share.shareXFiles(
      [XFile(imagePath)],
      text: 'Check out my Doggelganger, ${widget.dog.name}!',
      subject: 'My Doggelganger Match',
    );

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shared successfully!')),
      );
    } else if (result.status == ShareResultStatus.dismissed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share cancelled')),
      );
    }
  }

  Future<void> _launchAdoptionLink() async {
    final Uri url = Uri.parse(widget.dog.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Logger().e('Could not launch ${url.toString()}');
    }
  }
}
