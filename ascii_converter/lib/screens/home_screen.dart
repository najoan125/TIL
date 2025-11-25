import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../logic/ascii_converter_logic.dart';
import '../widgets/ascii_viewer.dart';
import '../widgets/settings_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _asciiArt;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  // Settings
  int _width = 100;
  double _contrast = 1.0;
  double _brightness = 0.0;
  String _charSet = 'Simple';
  bool _invert = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
      _convertImage();
    }
  }

  Future<void> _convertImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ascii = await AsciiConverterLogic.convertImage(
        _imageBytes!,
        width: _width,
        contrast: _contrast,
        brightness: _brightness,
        charSet: _charSet,
        invert: _invert,
      );
      setState(() {
        _asciiArt = ascii;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error converting image: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SettingsPanel(
        width: _width,
        contrast: _contrast,
        brightness: _brightness,
        charSet: _charSet,
        invert: _invert,
        onWidthChanged: (val) {
          setState(() => _width = val);
          _convertImage();
        },
        onContrastChanged: (val) {
          setState(() => _contrast = val);
          _convertImage();
        },
        onBrightnessChanged: (val) {
          setState(() => _brightness = val);
          _convertImage();
        },
        onCharSetChanged: (val) {
          setState(() => _charSet = val);
          _convertImage();
        },
        onInvertChanged: (val) {
          setState(() => _invert = val);
          _convertImage();
        },
      ),
    );
  }

  Future<void> _shareAscii() async {
    if (_asciiArt == null) return;
    await Share.share(_asciiArt!);
  }

  Future<void> _copyToClipboard() async {
    if (_asciiArt == null) return;
    await Clipboard.setData(ClipboardData(text: _asciiArt!));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

  Future<void> _saveAscii() async {
    if (_asciiArt == null) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/ascii_art_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(_asciiArt!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASCII Converter'),
        actions: [
          if (_asciiArt != null) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copy',
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveAscii,
              tooltip: 'Save as Text',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareAscii,
              tooltip: 'Share',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettings,
              tooltip: 'Settings',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _asciiArt != null
          ? AsciiViewer(asciiArt: _asciiArt!)
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select an image to convert',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
            ),
      floatingActionButton: _asciiArt != null
          ? FloatingActionButton(
              onPressed: _pickImage,
              child: const Icon(Icons.add_photo_alternate),
            )
          : null,
    );
  }
}
