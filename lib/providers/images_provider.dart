import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/image_item.dart';
import '../services/image_processor_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ImagesState {
  final List<ImageItem> images;
  final String? outputFolder;
  final bool isSaving;

  const ImagesState({
    this.images = const [],
    this.outputFolder,
    this.isSaving = false,
  });

  ImagesState copyWith({
    List<ImageItem>? images,
    String? outputFolder,
    bool? isSaving,
  }) {
    return ImagesState(
      images: images ?? this.images,
      outputFolder: outputFolder ?? this.outputFolder,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  int get pendingCount =>
      images.where((i) => i.status == ProcessStatus.pending).length;
  int get doneCount =>
      images.where((i) => i.status == ProcessStatus.done).length;
  int get processingCount =>
      images.where((i) => i.status == ProcessStatus.processing).length;
  bool get allDone =>
      images.isNotEmpty && images.every((i) => i.status == ProcessStatus.done);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ImagesNotifier extends StateNotifier<ImagesState> {
  final _processor = ImageProcessorService();

  ImagesNotifier() : super(const ImagesState());

  static const _supportedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.webp',
    '.tiff',
    '.tif',
  };

  bool _isImage(String path) =>
      _supportedExtensions.contains(p.extension(path).toLowerCase());

  // ── Add images from drop or file picker ──────────────────────────────────

  void addImages(List<String> paths) {
    final existing = state.images.map((i) => i.sourcePath).toSet();

    final newItems = paths
        .where(_isImage)
        .where((path) => !existing.contains(path))
        .map((path) => ImageItem(sourcePath: path, fileName: p.basename(path)))
        .toList();

    if (newItems.isEmpty) return;

    state = state.copyWith(images: [...state.images, ...newItems]);

    // Auto-process newly added images
    for (final item in newItems) {
      _processOne(item.sourcePath);
    }
  }

  void removeImage(String sourcePath) {
    state = state.copyWith(
      images: state.images.where((i) => i.sourcePath != sourcePath).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(images: []);
  }

  // ── Process ──────────────────────────────────────────────────────────────

  Future<void> _processOne(String sourcePath) async {
    _updateItem(
      sourcePath,
      (item) => item.copyWith(status: ProcessStatus.processing),
    );

    try {
      final result = await _processor.processImage(sourcePath);
      _updateItem(
        sourcePath,
        (item) => item.copyWith(
          status: ProcessStatus.done,
          processedBytes: result.bytes,
          originalWidth: result.originalWidth,
          originalHeight: result.originalHeight,
          paddedWidth: result.paddedWidth,
          paddedHeight: result.paddedHeight,
        ),
      );
    } catch (e) {
      _updateItem(
        sourcePath,
        (item) => item.copyWith(
          status: ProcessStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void retryImage(String sourcePath) => _processOne(sourcePath);

  void _updateItem(String sourcePath, ImageItem Function(ImageItem) update) {
    state = state.copyWith(
      images: state.images.map((item) {
        return item.sourcePath == sourcePath ? update(item) : item;
      }).toList(),
    );
  }

  // ── Output folder ─────────────────────────────────────────────────────────

  Future<void> pickOutputFolder() async {
    final folder = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose output folder',
    );
    if (folder != null) {
      state = state.copyWith(outputFolder: folder);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<int> saveAll() async {
    if (state.outputFolder == null) return 0;

    state = state.copyWith(isSaving: true);
    int saved = 0;

    for (final item in state.images) {
      if (item.status != ProcessStatus.done || item.processedBytes == null) {
        continue;
      }

      final outPath = p.join(
        state.outputFolder!,
        'wallet_${item.fileName.replaceAll(RegExp(r'\.(jpg|jpeg|png|bmp|webp|tiff|tif)$', caseSensitive: false), '.jpg')}',
      );

      await File(outPath).writeAsBytes(item.processedBytes!);
      saved++;
    }

    state = state.copyWith(isSaving: false);
    return saved;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final imagesProvider = StateNotifierProvider<ImagesNotifier, ImagesState>((
  ref,
) {
  return ImagesNotifier();
});

// Expose the processor result type publicly for widgets
class ProcessResult {
  final List<int> bytes;
  final int originalWidth;
  final int originalHeight;
  final int paddedWidth;
  final int paddedHeight;

  ProcessResult({
    required this.bytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.paddedWidth,
    required this.paddedHeight,
  });
}
