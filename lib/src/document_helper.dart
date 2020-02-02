import 'dart:io';

import 'package:framy/src/model/file_name.dart';
import 'package:framy/src/model/svg_document.dart';

class DocumentHelper {
  final String svgFileName;
  const DocumentHelper({this.svgFileName = 'framy.svg'});

  List<FrameName> prepareFrameNames(String directoryPath) {
    List<String> fileNames = [];
    Directory directory = Directory(directoryPath);
    List<FileSystemEntity> files = directory.listSync();
    //iterate through all files in given directory
    for (FileSystemEntity f in files) {
      fileNames.add(f.path.replaceAll(f.parent.path + '/', ''));
    }

    fileNames = fileNames.map((p) => p.replaceAll('.png', '')).toList();
    List<FrameName> fileNamesObjects = fileNames.map<FrameName>((name) {
      List<String> nameParts = name.split('-');
      return FrameName(nameParts[0], nameParts[1]);
    }).toList();
    return fileNamesObjects;
  }

  Future<void> saveSvg(
      SvgDocument document, double width, double height) async {
    String svgContent = document.toSvgPath(width, height);
    return File(svgFileName).writeAsString(svgContent);
  }
}
