import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/image_item.dart';
import '../providers/images_provider.dart';

class ImageCard extends ConsumerWidget {
  final ImageItem item;

  const ImageCard({required this.item, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E3E), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Thumbnail ─────────────────────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbnail(),
                // Status overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: _StatusBadge(status: item.status),
                ),
                // Remove button
                Positioned(
                  top: 8,
                  left: 8,
                  child: _RemoveButton(
                    onTap: () => ref
                        .read(imagesProvider.notifier)
                        .removeImage(item.sourcePath),
                  ),
                ),
              ],
            ),
          ),

          // ── Info ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.status == ProcessStatus.done) ...[
                  Text(
                    '${item.originalWidth}×${item.originalHeight}  →  ${item.paddedWidth}×${item.paddedHeight}',
                    style: const TextStyle(
                      color: Color(0xFF888899),
                      fontSize: 10,
                    ),
                  ),
                ] else if (item.status == ProcessStatus.error) ...[
                  GestureDetector(
                    onTap: () => ref
                        .read(imagesProvider.notifier)
                        .retryImage(item.sourcePath),
                    child: const Text(
                      'Tap to retry',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 10,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    '...',
                    style: TextStyle(color: Color(0xFF888899), fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (item.status == ProcessStatus.done && item.processedBytes != null) {
      // Show the padded result
      return Image.memory(item.processedBytes!, fit: BoxFit.contain);
    }

    if (item.status == ProcessStatus.processing) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(item.sourcePath), fit: BoxFit.cover),
          Container(
            color: Colors.black45,
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF6B9FFF),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (item.status == ProcessStatus.error) {
      return Container(
        color: const Color(0xFF2A1E1E),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFFFF6B6B),
            size: 32,
          ),
        ),
      );
    }

    // Pending — show original
    return Image.file(File(item.sourcePath), fit: BoxFit.cover);
  }
}

class _StatusBadge extends StatelessWidget {
  final ProcessStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      ProcessStatus.pending => (Icons.hourglass_empty, const Color(0xFFAAAAAA)),
      ProcessStatus.processing => (Icons.autorenew, const Color(0xFF6B9FFF)),
      ProcessStatus.done => (Icons.check_circle, const Color(0xFF6BFF9F)),
      ProcessStatus.error => (Icons.error_outline, const Color(0xFFFF6B6B)),
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.close, color: Colors.white70, size: 14),
      ),
    );
  }
}
