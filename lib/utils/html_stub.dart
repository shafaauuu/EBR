class ImageElement {
  String? id;
  String? src;
  final style = ImageElementStyle();
  int? width;
  int? height;
}

class ImageElementStyle {
  String? height;
  String? objectFit;
}

class CanvasElement {
  CanvasElement({this.width, this.height});
  final int? width;
  final int? height;
  CanvasRenderingContext2D get context2D => CanvasRenderingContext2D();
  String toDataUrl(String type) => '';
}

class CanvasRenderingContext2D {
  void drawImage(ImageElement image, int x, int y) {}
}

class Document {
  Body? body;
}

class Body {
  void append(ImageElement element) {}
}

// Stub for document global variable
final document = Document()..body = Body();
