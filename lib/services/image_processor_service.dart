import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessorService {
  Future<_ProcessResult> processImage(String sourcePath) async {
    return await Isolate.run(() => _processInIsolate(sourcePath));
  }

  static _ProcessResult _processInIsolate(String sourcePath) {
    final bytes = File(sourcePath).readAsBytesSync();
    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception('Could not decode image: $sourcePath');
    }

    final originalWidth = original.width;
    final originalHeight = original.height;

    // Step 1: rotate landscape to portrait
    final working = originalWidth > originalHeight
        ? img.copyRotate(original, angle: 90)
        : original;

    final int paddingWidth = (working.height * 1 / 2).round();
    final int paddingHeight = (working.width * 2 / 3).round();

    final int canvasWidth = working.width + paddingWidth;
    final int canvasHeight = working.height + paddingHeight;

    // Step 3: white canvas, image pasted top-left
    final canvas = img.Image(
      width: canvasWidth,
      height: canvasHeight,
      numChannels: 3,
    );
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(canvas, working, dstX: 0, dstY: 0);

    final outputBytes = Uint8List.fromList(img.encodeJpg(canvas, quality: 95));

    return _ProcessResult(
      bytes: outputBytes,
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      paddedWidth: canvasWidth,
      paddedHeight: canvasHeight,
    );
  }
}

class _ProcessResult {
  final Uint8List bytes;
  final int originalWidth;
  final int originalHeight;
  final int paddedWidth;
  final int paddedHeight;

  _ProcessResult({
    required this.bytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.paddedWidth,
    required this.paddedHeight,
  });
}
