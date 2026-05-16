import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wallet_image_processor/providers/settings_provider.dart';
import 'package:path/path.dart' as p;

import '../models/image_item.dart';
import '../models/settings_model.dart';
import '../models/process_result_model.dart';
import '../services/image_processor_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ImagesState {
  final List<ImageItem> images;
  final String? outputFolder;
  final bool isSaving;
  final bool isReprocessing;

  const ImagesState({
    this.images = const [],
    this.outputFolder,
    this.isSaving = false,
    this.isReprocessing = false,
  });

  ImagesState copyWith({
    List<ImageItem>? images,
    String? outputFolder,
    bool? isSaving,
    bool? isReprocessing,
  }) {
    return ImagesState(
      images: images ?? this.images,
      outputFolder: outputFolder ?? this.outputFolder,
      isSaving: isSaving ?? this.isSaving,
      isReprocessing: isReprocessing ?? this.isReprocessing,
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
  final Ref _ref;

  ImagesNotifier(this._ref) : super(const ImagesState()) {
    print("created images notifier");
  }

  static const supportedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.webp',
    '.tiff',
    '.tif',
  };

  bool _isImage(String path) =>
      supportedExtensions.contains(p.extension(path).toLowerCase());

  ProcessingSettings get _settings => _ref.read(settingsProvider);

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

  Future<void> _processOne(String sourcePath, dynamic existingBytes) async {
    _updateItem(
      sourcePath,
      (item) => item.copyWith(status: ProcessStatus.processing),
    );

    try {
      final settings = _settings;
      final ProcessResult result;
      if (existingBytes != null) {
        result = await _processor.reprocessImage(existingBytes, settings);
      } else {
        result = await _processor.processImage(sourcePath, settings);
      }
      _updateItem(
        sourcePath,
        (item) => item.copyWith(
          status: ProcessStatus.done,
          originalBytes: result.originalBytes,
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

  void retryImage(String sourcePath) {
    final item = state.images.firstWhere((i) => i.sourcePath == sourcePath);
    _processOne(sourcePath, item.originalBytes);
  }

  Future<void> processAll() async {
    if (state.images.isEmpty) return;
    await Future.wait(
      state.images.map(
        (item) => _processOne(item.sourcePath, item.originalBytes),
      ),
    );
  }

  void _updateItem(String sourcePath, ImageItem Function(ImageItem) update) {
    state = state.copyWith(
      images: state.images.map((item) {
        return item.sourcePath == sourcePath ? update(item) : item;
      }).toList(),
    );
  }

  // ── Output folder ─────────────────────────────────────────────────────────

  Future<void> pickOutputFolder() async {
    final folder = await FilePicker.getDirectoryPath(
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
        '${_settings.processedPrefix}_${item.fileName.replaceAll(RegExp(r'\.(jpg|jpeg|png|bmp|webp|tiff|tif)$', caseSensitive: false), '.jpg')}',
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
  final notifier = ImagesNotifier(ref);
  return notifier;
});
