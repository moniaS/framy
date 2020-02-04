import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:framy/src/wireframes_generator.dart';

const rootFolderName = "framy";

/// [Framy] is the class responsible for taking screenshots
/// and generating wireframes structure from them
class Framy {
  final String groupName;
  final FlutterDriver driver;
  var _shouldDeleteSourceDirectory = true;

  Framy({this.groupName = 'default', this.driver});

  /// Takes screenshot with given screenshotName and saves it at the directory
  Future<void> takeScreenshot(String screenshotName) async {
    assert(driver != null);
    if (_shouldDeleteSourceDirectory) {
      await _deleteExistingGroupFolder();
      _shouldDeleteSourceDirectory = false;
    }
    final filePath = _filePath('$screenshotName.png');
    final file = await File(filePath).create(recursive: true);
    final pixels = await driver.screenshot();
    await file.writeAsBytes(pixels);
    print('Framy took screenshot: $filePath');
  }

  /// Generates wireframes structure from given directory of screenshots
  /// File names should be in the following format: '1-login_page.png',
  /// '1.1-homepage.png', '1.1.1-page_1.png', '1.1.2-page_2.png' etc
  /// where '1.1', '1.1.1', '1.1.1.1' mean nesting hierarchy and 'homepage',
  /// 'login_page' mean pages names
  void generateWireFrames(String directoryPath, String initialFileName) {
    final generator = WireFramesGenerator(directoryPath, initialFileName);
    generator.generateWireFrames();
  }

  Future _deleteExistingGroupFolder() async {
    final groupFolder = Directory('$rootFolderName/$groupName');
    if (await groupFolder.exists()) {
      await groupFolder.delete(recursive: true);
      print('Framy has deleted the "$groupName" folder');
    }
  }

  String _filePath(String fileName) {
    return '$rootFolderName/$groupName/$fileName';
  }
}
