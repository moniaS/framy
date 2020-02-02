import 'dart:convert';
import 'dart:io';

class SvgElement {}

class SvgLine extends SvgElement {
  final double startingX;
  final double startingY;
  final double endingX;
  final double endingY;

  SvgLine(this.startingX, this.startingY, this.endingX, this.endingY);

  @override
  String toString() {
    return '<line x1="$startingX" y1="$startingY" x2="$endingX" y2="$endingY" style="stroke:rgb(122,122,122);stroke-width:1" />';
  }

  @override
  bool operator ==(other) {
    return other is SvgLine &&
        startingX == other.startingX &&
        startingY == other.startingY &&
        endingX == other.endingX &&
        endingY == other.endingY;
  }

  @override
  int get hashCode =>
      startingX.hashCode ^
      startingY.hashCode ^
      endingX.hashCode ^
      endingY.hashCode;
}

class SvgImage extends SvgElement {
  final String path;
  final double x;
  final double y;

  SvgImage(this.path, this.x, this.y);

  @override
  String toString() {
    File imageFile = new File(path);
    String base64Image;
    try {
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
    } catch (e) {
      base64Image = '';
    }

    return '<image href="data:image/png;base64,$base64Image" x="$x" y="$y"/>';
  }

  @override
  bool operator ==(other) {
    print(path);
    print(other.path);
    print(path == other.path);
    print(x == other.x);
    print(y == other.y);
    return other is SvgImage &&
        path == other.path &&
        x == other.x &&
        y == other.y;
  }

  @override
  int get hashCode => path.hashCode ^ x.hashCode ^ y.hashCode;
}

class SvgName extends SvgElement {
  final String name;
  final double x;
  final double y;

  SvgName(this.name, this.x, this.y);

  @override
  String toString() {
    return '<text x="$x" y="$y" fill="black" font-family="Arial, Helvetica, sans-serif" font-size="10">$name</text>';
  }
}
