import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/images_provider.dart';

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imagesProvider);
    final notifier = ref.read(imagesProvider.notifier);

    final canSave =
        state.allDone && state.outputFolder != null && !state.isSaving;
    final hasImages = state.images.isNotEmpty;

    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF13131C),
        border: Border(top: BorderSide(color: Color(0xFF2A2A3A), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Stats ───────────────────────────────────────────────────
          if (hasImages) ...[
            _Stat(
              label: 'Total',
              value: '${state.images.length}',
              color: const Color(0xFF888899),
            ),
            const SizedBox(width: 20),
            _Stat(
              label: 'Done',
              value: '${state.doneCount}',
              color: const Color(0xFF6BFF9F),
            ),
            if (state.processingCount > 0) ...[
              const SizedBox(width: 20),
              _Stat(
                label: 'Processing',
                value: '${state.processingCount}',
                color: const Color(0xFF6B9FFF),
              ),
            ],
          ],

          const Spacer(),

          // ── Clear button ─────────────────────────────────────────────
          if (hasImages)
            TextButton(
              onPressed: notifier.clearAll,
              child: const Text(
                'Clear all',
                style: TextStyle(color: Color(0xFF666677), fontSize: 13),
              ),
            ),

          const SizedBox(width: 12),

          // ── Output folder button ──────────────────────────────────────
          _FolderButton(
            folder: state.outputFolder,
            onTap: notifier.pickOutputFolder,
          ),

          const SizedBox(width: 12),

          // ── Save button ───────────────────────────────────────────────
          _SaveButton(
            canSave: canSave,
            isSaving: state.isSaving,
            onSave: () async {
              final saved = await notifier.saveAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$saved image${saved == 1 ? '' : 's'} saved to ${state.outputFolder}',
                    ),
                    backgroundColor: const Color(0xFF1E2E1E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF555566), fontSize: 12),
        ),
      ],
    );
  }
}

class _FolderButton extends StatelessWidget {
  final String? folder;
  final VoidCallback onTap;

  const _FolderButton({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = folder != null
        ? folder!.split(RegExp(r'[/\\]')).last
        : 'Choose output folder';

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.folder_open_outlined, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: folder != null
            ? const Color(0xFFCCCCDD)
            : const Color(0xFF888899),
        side: BorderSide(
          color: folder != null
              ? const Color(0xFF3E3E5E)
              : const Color(0xFF2E2E3E),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool canSave;
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveButton({
    required this.canSave,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: canSave ? onSave : null,
      icon: isSaving
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save_alt_outlined, size: 16),
      label: Text(isSaving ? 'Saving…' : 'Save all'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF6B9FFF),
        disabledBackgroundColor: const Color(0xFF2A2A3A),
        disabledForegroundColor: const Color(0xFF555566),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
