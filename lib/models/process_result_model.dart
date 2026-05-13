import 'dart:typed_data';

class ProcessResult {
  final Uint8List originalBytes;
  final Uint8List bytes;
  final int originalWidth;
  final int originalHeight;
  final int paddedWidth;
  final int paddedHeight;

  ProcessResult({
    required this.originalBytes,
    required this.bytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.paddedWidth,
    required this.paddedHeight,
  });
}
