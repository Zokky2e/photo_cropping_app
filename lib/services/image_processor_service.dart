import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../models/settings_model.dart';
import '../models/process_result_model.dart';

class ImageProcessorService {
  Future<ProcessResult> processImage(
    String sourcePath,
    ProcessingSettings settings,
  ) async {
    final originalBytes = await File(sourcePath).readAsBytes();
    return _runInIsolate(originalBytes, settings);
  }

  Future<ProcessResult> _runInIsolate(
    Uint8List originalBytes,
    ProcessingSettings settings,
  ) async {
    return await Isolate.run(() => _processInIsolate(originalBytes, settings));
  }

  static ProcessResult _processInIsolate(
    Uint8List originalBytes,
    ProcessingSettings settings,
  ) {
    final original = img.decodeImage(originalBytes);

    if (original == null) {
      throw Exception('Could not decode image');
    }

    final originalWidth = original.width;
    final originalHeight = original.height;

    // Step 1: rotate landscape to portrait
    final working = originalWidth > originalHeight
        ? img.copyRotate(original, angle: 90)
        : original;

    final int paddingWidth = (working.height * settings.widthPadding).round();
    final int paddingHeight = (working.width * settings.heightPadding).round();

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

    final outputBytes = Uint8List.fromList(
      img.encodeJpg(canvas, quality: settings.outputQuality),
    );

    return ProcessResult(
      originalBytes: originalBytes,
      bytes: outputBytes,
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      paddedWidth: canvasWidth,
      paddedHeight: canvasHeight,
    );
  }
}
