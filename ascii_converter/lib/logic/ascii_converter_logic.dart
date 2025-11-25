import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class AsciiConverterLogic {
  static Future<String> convertImage(
    Uint8List imageBytes, {
    int width = 100,
    double contrast = 1.0,
    double brightness = 0.0,
    String charSet = 'Simple',
    bool invert = false,
  }) async {
    // Use compute, which works on both mobile (isolate) and web (main thread)
    return compute(_convert, {
      'bytes': imageBytes,
      'width': width,
      'contrast': contrast,
      'brightness': brightness,
      'charSet': charSet,
      'invert': invert,
    });
  }
}

// Top-level function that is completely self-contained
String _convert(Map<String, dynamic> params) {
  final Uint8List imageBytes = params['bytes'];
  final int width = params['width'];
  final double contrast = params['contrast'];
  final double brightness = params['brightness'];
  final String charSetType = params['charSet'];
  final bool invert = params['invert'];

  // Define constants inside to avoid any potential closure capture issues
  const String simpleChars = '@%#*+=-:. ';
  const String complexChars =
      '\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,"^`\'. ';
  const String blockChars = '█▓▒░ ';

  final image = img.decodeImage(imageBytes);

  if (image == null) {
    return 'Could not decode image.';
  }

  // Resize maintaining aspect ratio
  final resizedImage = img.copyResize(image, width: width);

  // Get the character set
  String chars;
  switch (charSetType) {
    case 'Complex':
      chars = complexChars;
      break;
    case 'Blocks':
      chars = blockChars;
      break;
    case 'Simple':
    default:
      chars = simpleChars;
  }

  if (invert) {
    chars = chars.split('').reversed.join('');
  }

  final buffer = StringBuffer();
  for (int y = 0; y < resizedImage.height; y++) {
    for (int x = 0; x < resizedImage.width; x++) {
      final pixel = resizedImage.getPixel(x, y);

      // Calculate grayscale brightness
      double b = (pixel.r + pixel.g + pixel.b) / 3.0;

      // Apply contrast and brightness
      b = (b - 128) * contrast + 128 + brightness;

      // Clamp values
      b = b.clamp(0, 255).toDouble();

      final charIndex = (b / 255 * (chars.length - 1)).round();
      buffer.write(chars[charIndex]);
    }
    buffer.writeln();
  }
  return buffer.toString();
}
