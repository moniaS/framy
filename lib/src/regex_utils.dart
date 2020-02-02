import 'package:framy/src/model/file_name.dart';

List<FrameName> getSortedFrameChildren(
    List<FrameName> fileNames, FrameName parentName) {
  final pattern = r'^' + parentName.node + r'\.[0-9]+$';
  final regex = RegExp(pattern);
  List<FrameName> children =
      fileNames.where((p) => regex.hasMatch(p.node)).toList();
  _sortChildren(children);
  return children;
}

void _sortChildren(List<FrameName> children) {
  children.sort((a, b) {
    int lastDotIndex = a.node.lastIndexOf(('.'));
    int lastChildNumberA =
        int.tryParse(a.node.substring(lastDotIndex + 1, a.node.length));
    int lastChildNumberB =
        int.tryParse(b.node.substring(lastDotIndex + 1, b.node.length));
    return lastChildNumberA.compareTo(lastChildNumberB);
  });
}
