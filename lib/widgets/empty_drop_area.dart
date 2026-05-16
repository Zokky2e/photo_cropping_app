import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wallet_image_processor/providers/images_provider.dart';

class EmptyDropArea extends StatelessWidget {
  final void Function(List<String> paths) onFilesSelected;

  const EmptyDropArea({required this.onFilesSelected, super.key});

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      onFilesSelected(result.paths.whereType<String>().toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFiles,
      behavior: HitTestBehavior.opaque, // makes the whole area tappable
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E2E3E), width: 1.5),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 44,
                color: Color(0xFF4E4E6A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Drop images here',
              style: TextStyle(
                color: Color(0xFFCCCCDD),
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'or click to browse',
              style: TextStyle(color: Color(0xFF666677), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${ImagesNotifier.supportedExtensions.map((e) => e.replaceFirst('.', '').toUpperCase()).join(', ')} supported',
              style: const TextStyle(color: Color(0xFF444455), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
