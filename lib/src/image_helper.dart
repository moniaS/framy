import 'dart:io';

import 'package:image/image.dart';

/// [ImageHelper] is the class responsible for calculating image width based on file and its height
class ImageHelper {
  const ImageHelper();
  double calculateImageWidth(File imageFile, double height) {
    Image image = decodeImage(imageFile.readAsBytesSync());
    return height * image.width / image.height;
  }
}
