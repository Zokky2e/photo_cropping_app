import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/providers/settings_provider.dart';
import 'package:my_desktop_app/services/settings_window_manager.dart';

import '../providers/images_provider.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/top_bar.dart';
import '../widgets/drop_zone.dart';
import '../widgets/empty_drop_area.dart';
import '../widgets/image_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _registerChannelHandler();
  }

  void _registerChannelHandler() {
    final channel = WindowMethodChannel(
      'settings_channel',
      mode: ChannelMode.unidirectional,
    );
    print("creating method handler");
    channel.setMethodCallHandler((call) async {
      print(call.method);
      print(call.arguments);
      switch (call.method) {
        case 'settings_updated':
          final data = call.arguments;

          ref
              .read(settingsProvider.notifier)
              .updateSettings(
                heightPadding: data['heightPadding'],
                widthPadding: data['widthPadding'],
                outputQuality: data['outputQuality'],
                processedPrefix: data['processedPrefix'],
              );

          await ref.read(imagesProvider.notifier).reprocessAll();
          break;
        case 'settings_hide':
          await SettingsWindow.hide();
          break;
        default:
          print("unhandled_case");
          break;
      }

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            TopBar(
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
