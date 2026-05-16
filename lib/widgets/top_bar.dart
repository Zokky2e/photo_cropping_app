import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wallet_image_processor/main.dart' show appName, version;
import 'package:wallet_image_processor/services/settings_window_manager.dart';
import 'package:wallet_image_processor/widgets/windows_controls.dart';
import 'package:window_manager/window_manager.dart';

class TopBar extends StatelessWidget {
  final int imageCount;
  final void Function(List<String> paths) onAddImages;

  const TopBar({
    super.key,
    required this.imageCount,
    required this.onAddImages,
  });

  Future<void> _openSettings() async {
    await SettingsWindow.toggle();
  }

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
    return DragToMoveArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF13131C),
          border: Border(
            bottom: BorderSide(color: Color(0xFF1E1E2E), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(version, style: TextStyle(fontSize: 8)),
                  WindowControls(),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.photo_size_select_large,
                      color: Color(0xFF6B9FFF),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      appName,
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
                        style: const TextStyle(
                          color: Color(0xFF555566),
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 16,
                      ),
                      label: const Text('Add images'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCCCCDD),
                        side: const BorderSide(color: Color(0xFF3E3E5E)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Settings'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCCCCDD),
                        side: const BorderSide(color: Color(0xFF3E3E5E)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
