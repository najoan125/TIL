import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascii_converter/logic/ascii_converter_logic.dart';
import 'package:image/image.dart' as img;

void main() {
  test('AsciiConverterLogic converts image successfully', () async {
    // Create a temporary image file
    final image = img.Image(width: 10, height: 10);
    // Fill with some color
    for (var p in image) {
      p.r = 255;
      p.g = 255;
      p.b = 255;
    }

    final png = img.encodePng(image);
    // We don't need a temp file anymore, we can pass bytes directly

    try {
      final ascii = await AsciiConverterLogic.convertImage(png, width: 10);
      expect(ascii, isNotEmpty);
      print('ASCII Output:\n$ascii');
    } catch (e) {
      fail('Conversion failed: $e');
    }
  });
}
