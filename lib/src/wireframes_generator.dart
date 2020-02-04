import 'dart:io';
import 'dart:math';

import 'package:framy/src/document_helper.dart';
import 'package:framy/src/image_helper.dart';
import 'package:framy/src/model/file_name.dart';
import 'package:framy/src/model/svg_document.dart';
import 'package:framy/src/model/svg_element.dart';
import 'package:framy/src/regex_utils.dart';

/// [WireFramesGenerator] is the class responsible for building wireframes
/// structure and saving it in svg file
class WireFramesGenerator {
  final Frame initialFrame;
  final String directoryPath;
  final DocumentHelper documentHelper;
  final double imageWidth;

  WireFramesGenerator(
    this.directoryPath,
    String initialFrameName, {
    this.documentHelper = const DocumentHelper(),
    double imageWidth,
  })  : this.imageWidth = imageWidth ??
            ImageHelper().calculateImageWidth(
              File('$directoryPath/$initialFrameName.png'),
              Position.imageHeight,
            ),
        this.initialFrame = Frame(
            initialFrameName.split('-')[0], initialFrameName.split('-')[1]);

  /// Generates svg file containing application structure based on images from given directory.
  /// Starts drawing from initialFrameName file.
  void generateWireFrames() async {
    List<Frame> fileNames = documentHelper.prepareFrameNames(directoryPath);
    List<int> depthsList =
        fileNames.map((name) => '.'.allMatches(name.node).length).toList();
    int maxDepth = depthsList.reduce(max) + 1;
    final svgDocument = SvgDocument();
    int verticalGrowth = _drawNode(
      initialFrame,
      fileNames,
      0,
      imageWidth,
      svgDocument,
    );
    await documentHelper.saveSvg(
      svgDocument,
      maxDepth * (imageWidth + Position.lineWidth),
      Position.topStartingPosition +
          (verticalGrowth + 1) *
              (Position.imageHeight + Position.verticalMargin),
    );
  }

  /// Recursively generates wireframes structure.
  /// For every parent node draws every direct child node and connecting lines.
  int _drawNode(
    Frame parentFileName,
    List<Frame> fileNames,
    int verticalDepth,
    double imageWidth,
    SvgDocument document,
  ) {
    //get horizontal depth of wireframe in this node
    final int horizontalDepth = _getHorizontalDepth(parentFileName.node);
    //create position object
    final Position position =
        Position(horizontalDepth, verticalDepth, imageWidth);
    //add image and name to the document
    _addImageWithName(document, parentFileName, position, imageWidth);
    //get sorted all the frames directly connected to this node
    List<Frame> children = getSortedFrameChildren(fileNames, parentFileName);
    int verticalGrowth = 0;
    //repeat for every direct child
    for (Frame child in children) {
      //set starting position for vertical line
      position.setLineStartingPositionY(verticalGrowth);
      //draw horizontal line
      _addHorizontalLine(children.first == child, position, document);
      // call function for every child recursively
      verticalGrowth += _drawNode(child, fileNames,
          verticalDepth + verticalGrowth, imageWidth, document);
      verticalGrowth += 1;
    }
    // when there are more than one child then add vertical line, which connects all children
    _addVerticalLine(children.length, position, document);
    if (children.isNotEmpty) {
      verticalGrowth--;
    }
    return verticalGrowth;
  }

  /// Adds horizontal line to connect vertical line with every direct children
  void _addHorizontalLine(
    bool isFirstChild,
    Position position,
    SvgDocument document,
  ) {
    // for first child add first half of horizontal line
    if (isFirstChild) {
      _addConnectingLineForFirstChild(
        position,
        document,
      );
    }
    // add second half of horizontal line for every child
    document.addElement(SvgLine(
        position.lineStartingPositionX + 1 / 2 * Position.lineWidth,
        position.lineStartingPositionY,
        position.lineEndingPositionX,
        position.lineStartingPositionY));
  }

  int _getHorizontalDepth(String parentNode) {
    return '.'.allMatches(parentNode).length;
  }

  /// Adds image with name to the svg document
  void _addImageWithName(
    SvgDocument document,
    Frame parentFileName,
    Position position,
    double imageWidth,
  ) {
    //add SvgImage to the SvgDocument
    document.addElement(SvgImage(
      '$directoryPath/${parentFileName.node}-${parentFileName.name}.png',
      position.imagePositionX,
      position.imagePositionY,
      imageWidth,
    ));

    //add SvgName to the SvgDocument
    document.addElement(
      SvgName(
        parentFileName.name,
        position.imagePositionX,
        position.imagePositionY - 10,
      ),
    );
  }

  /// Adds horizontal starting line for first child to the svg document
  void _addConnectingLineForFirstChild(
      Position position, SvgDocument document) {
    document.addElement(
      SvgLine(
        position.lineStartingPositionX,
        position.lineStartingPositionY,
        position.lineStartingPositionX + 1 / 2 * Position.lineWidth,
        position.lineStartingPositionY,
      ),
    );
  }

  /// Adds vertical line to connect all children lines to the svg document
  void _addVerticalLine(
    int childrenLength,
    Position position,
    SvgDocument document,
  ) {
    if (childrenLength > 1) {
      document.addElement(
        SvgLine(
            position.lineStartingPositionX + 1 / 2 * Position.lineWidth,
            position.imagePositionY + 1 / 2 * Position.imageHeight,
            position.lineStartingPositionX + 1 / 2 * Position.lineWidth,
            position.lineStartingPositionY),
      );
    }
  }
}

class Position {
  final int horizontalDepth;
  final int verticalDepth;
  final double imageWidth;
  static final double topStartingPosition = 50;
  static final double leftStartingPosition = 50;
  static final double lineWidth = 50;
  static final double verticalMargin = 50;
  static final double imageHeight = 300;
  double lineStartingPositionY;

  Position(this.horizontalDepth, this.verticalDepth, this.imageWidth);

  double get imagePositionX =>
      leftStartingPosition + horizontalDepth * (imageWidth + lineWidth);

  double get imagePositionY =>
      topStartingPosition + verticalDepth * (imageHeight + verticalMargin);

  double get lineStartingPositionX => imagePositionX + imageWidth;

  double get lineEndingPositionX => lineStartingPositionX + lineWidth;

  double get linePositionY => lineStartingPositionY;

  void setLineStartingPositionY(int yGrow) {
    lineStartingPositionY = imagePositionY +
        (1 + 2 * yGrow) / 2 * imageHeight +
        verticalMargin * yGrow;
  }
}
