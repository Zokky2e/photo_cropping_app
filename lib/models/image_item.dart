import 'dart:typed_data';

enum ProcessStatus { pending, processing, done, error }

class ImageItem {
  final String sourcePath;
  final String fileName;
  ProcessStatus status;
  Uint8List? processedBytes;
  String? errorMessage;

  // Original dimensions (filled after decode)
  int? originalWidth;
  int? originalHeight;
  int? paddedWidth;
  int? paddedHeight;

  ImageItem({required this.sourcePath, required this.fileName})
    : status = ProcessStatus.pending;

  ImageItem copyWith({
    ProcessStatus? status,
    Uint8List? processedBytes,
    Uint8List? originalBytes,
    String? errorMessage,
    int? originalWidth,
    int? originalHeight,
    int? paddedWidth,
    int? paddedHeight,
  }) {
    final item = ImageItem(sourcePath: sourcePath, fileName: fileName);
    item.status = status ?? this.status;
    item.processedBytes = processedBytes ?? this.processedBytes;
    item.errorMessage = errorMessage ?? this.errorMessage;
    item.originalWidth = originalWidth ?? this.originalWidth;
    item.originalHeight = originalHeight ?? this.originalHeight;
    item.paddedWidth = paddedWidth ?? this.paddedWidth;
    item.paddedHeight = paddedHeight ?? this.paddedHeight;
    return item;
  }
}
