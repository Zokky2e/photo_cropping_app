import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../providers/images_provider.dart';
import '../services/settings_window_manager.dart';

class MethodChannelHandler {
  static void init(WidgetRef ref) {
    print("method channel handler initialized");
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
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

        case 'settings_closed':
          SettingsWindow.clearReference();
      }

      return null;
    });
  }
}
