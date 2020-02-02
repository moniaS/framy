import 'package:framy/src/model/svg_element.dart';

class SvgDocument {
  List<SvgElement> elements = [];

  void addElement(SvgElement element) {
    elements.add(element);
  }

  String toSvgPath(double width, double height) {
    String path = '<svg width="$width" height="$height" '
        'xmlns="http://www.w3.org/2000/svg">';
    for (SvgElement e in elements) {
      path += ' ${e.toString()}';
    }
    path += ' </svg>';
    return path;
  }
}
