library framy;

import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:meta/meta.dart';

const rootFolderName = "framy";

/// [Framy] is the class responsible for taking screenshots
class Framy {
  final FlutterDriver driver;
  final String groupName;
  final bool shouldTakeScreenshots;
  var _doesGroupFolderNeedToBeDeleted = true;

  Framy._internal(
    this.driver, {
    @required this.groupName,
    @required this.shouldTakeScreenshots,
  }) : assert(driver != null);

  factory Framy.initWith(
    FlutterDriver driver, {
    String groupName = "default",
    bool shouldTakeScreenshots = true,
  }) =>
      Framy._internal(
        driver,
        groupName: groupName,
        shouldTakeScreenshots: shouldTakeScreenshots,
      );

  Future takeScreenshot(String screenshotName) async {
    if (shouldTakeScreenshots) {
      if (_doesGroupFolderNeedToBeDeleted) {
        await _deleteExistingGroupFolder();
        _doesGroupFolderNeedToBeDeleted = false;
      }
      final filePath = _filePath(screenshotName);
      final file = await File(filePath).create(recursive: true);
      final pixels = await driver.screenshot();
      await file.writeAsBytes(pixels);
      print('Framy took screenshot: $filePath');
    }
  }

  Future _deleteExistingGroupFolder() async {
    final groupFolder = Directory(_groupFolderName);
    if (await groupFolder.exists()) {
      await groupFolder.delete(recursive: true);
      print('Framy has deleted the "$groupName" folder');
    }
  }

  String get _groupFolderName => '$rootFolderName/$groupName';

  String _fileName(String screenshotName) => '$screenshotName.png';

  String _filePath(String screenshotName) {
    final fileName = _fileName(screenshotName);
    return '$_groupFolderName/$fileName';
  }

  //TODO add method to generate wireframes
}
