import 'dart:io';
import 'dart:math';

import 'package:framy/src/document_helper.dart';
import 'package:framy/src/image_helper.dart';
import 'package:framy/src/model/file_name.dart';
import 'package:framy/src/model/svg_document.dart';
import 'package:framy/src/model/svg_element.dart';
import 'package:framy/src/regex_utils.dart';

class WireFramesGenerator {
  final FrameName _firstFrameName;
  final String directoryPath;
  final String firstFrameName;
  final DocumentHelper documentHelper;
  double imageWidth;

  WireFramesGenerator(
    this.directoryPath,
    this.firstFrameName, {
    this.documentHelper = const DocumentHelper(),
    double imageWidth,
  })  : this.imageWidth = imageWidth ??
            ImageHelper().calculateImageWidth(
              File('$directoryPath/$firstFrameName'),
              Position.imageHeight,
            ),
        this._firstFrameName = FrameName(
            firstFrameName.split('-')[0], firstFrameName.split('-')[1]);

  void generateWireFrames() async {
    List<FrameName> fileNames = documentHelper.prepareFrameNames(directoryPath);
    List<int> depthsList =
        fileNames.map((name) => '.'.allMatches(name.node).length).toList();
    int maxDepth = depthsList.reduce(max) + 1;
    final svgDocument = SvgDocument();
    int verticalGrowth = generateSvgDocument(
      _firstFrameName,
      fileNames,
      0,
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

  int generateSvgDocument(
    FrameName parentFileName,
    List<FrameName> fileNames,
    int verticalDepth,
    SvgDocument document,
  ) {
    //get horizontal depth of wireframe in this node
    final int horizontalDepth = getHorizontalDepth(parentFileName.node);
    //create position object
    final Position position =
        Position(horizontalDepth, verticalDepth, imageWidth);
    //add image and name to the document
    addImageWithName(document, parentFileName, position);
    //get sorted all the frames directly connected to this node
    List<FrameName> children =
        getSortedFrameChildren(fileNames, parentFileName);
    int verticalGrowth = 0;
    //repeat for every direct child
    for (FrameName child in children) {
      //set starting position for vertical line
      position.setLineStartingPositionY(verticalGrowth);
      //draw horizontal line
      addHorizontalLine(children.first == child, position, document);
      // call function for every child recursively
      verticalGrowth += generateSvgDocument(
          child, fileNames, verticalDepth + verticalGrowth, document);
      verticalGrowth += 1;
    }
    // when there are more than one child then add vertical line, which connects all children
    addVerticalLine(children.length, position, document);
    if (children.isNotEmpty) {
      verticalGrowth--;
    }
    return verticalGrowth;
  }

  void addHorizontalLine(
    bool isFirstChild,
    Position position,
    SvgDocument document,
  ) {
    // for first child add first half of horizontal line
    if (isFirstChild) {
      addConnectingLineForFirstChild(
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

  int getHorizontalDepth(String parentNode) {
    return '.'.allMatches(parentNode).length;
  }

  void addImageWithName(
    SvgDocument document,
    FrameName parentFileName,
    Position position,
  ) {
    //add SvgImage to the SvgDocument
    document.addElement(SvgImage(
      '$directoryPath/${parentFileName.node}-${parentFileName.name}.png',
      position.imagePositionX,
      position.imagePositionY,
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

  void addConnectingLineForFirstChild(Position position, SvgDocument document) {
    document.addElement(
      SvgLine(
        position.lineStartingPositionX,
        position.lineStartingPositionY,
        position.lineStartingPositionX + 1 / 2 * Position.lineWidth,
        position.lineStartingPositionY,
      ),
    );
  }

  void addVerticalLine(
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
