import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';

class AsciiViewer extends StatelessWidget {
  final String asciiArt;
  final double fontSize;

  const AsciiViewer({super.key, required this.asciiArt, this.fontSize = 8.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: PhotoView.customChild(
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained * 0.5,
        maxScale: PhotoViewComputedScale.covered * 5.0,
        initialScale: PhotoViewComputedScale.contained,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                asciiArt,
                style: GoogleFonts.robotoMono(
                  fontSize: fontSize,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
