import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/images_provider.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/drop_zone.dart';
import '../widgets/empty_drop_area.dart';
import '../widgets/image_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imagesProvider);
    final notifier = ref.read(imagesProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E16),
      body: DropZone(
        onFilesDropped: notifier.addImages,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _TopBar(
              imageCount: state.images.length,
              onAddImages: notifier.addImages,
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: state.images.isEmpty
                  ? EmptyDropArea(onFilesSelected: notifier.addImages)
                  : _ImageGrid(state: state),
            ),

            // ── Bottom bar ───────────────────────────────────────────────
            const BottomBar(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int imageCount;
  final void Function(List<String> paths) onAddImages;

  const _TopBar({required this.imageCount, required this.onAddImages});

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      onAddImages(result.paths.whereType<String>().toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF13131C),
        border: Border(bottom: BorderSide(color: Color(0xFF1E1E2E), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(
            Icons.photo_size_select_large,
            color: Color(0xFF6B9FFF),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Text(
            'Wallet Padder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '5:7 ratio',
            style: TextStyle(color: Color(0xFF444455), fontSize: 12),
          ),
          const Spacer(),
          if (imageCount > 0)
            Text(
              '$imageCount image${imageCount == 1 ? '' : 's'}',
              style: const TextStyle(color: Color(0xFF555566), fontSize: 12),
            ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
            label: const Text('Add images'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFCCCCDD),
              side: const BorderSide(color: Color(0xFF3E3E5E)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGrid extends ConsumerWidget {
  final ImagesState state;
  const _ImageGrid({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: state.images.length,
      itemBuilder: (context, index) {
        return ImageCard(item: state.images[index]);
      },
    );
  }
}
