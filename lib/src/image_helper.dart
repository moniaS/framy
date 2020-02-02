import 'dart:io';

import 'package:image/image.dart';

class ImageHelper {
  const ImageHelper();
  double calculateImageWidth(File imageFile, double height) {
    Image image = decodeImage(imageFile.readAsBytesSync());
    return height * image.width / image.height;
  }
}
