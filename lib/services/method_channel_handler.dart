import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/providers/images_provider.dart';
import 'package:my_desktop_app/providers/settings_provider.dart';
import 'package:my_desktop_app/services/settings_window_manager.dart';

class MethodChannelHandler {
  static void init(ProviderContainer container) {
    final channel = WindowMethodChannel('settings_channel');

    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'settings_updated':
          final data = call.arguments;

          container
              .read(settingsProvider.notifier)
              .updateSettings(
                heightPadding: data['heightPadding'],
                widthPadding: data['widthPadding'],
                outputQuality: data['outputQuality'],
                processedPrefix: data['processedPrefix'],
              );

          await container.read(imagesProvider.notifier).reprocessAll();
          break;

        case 'settings_closed':
          SettingsWindow.clearReference();
          break;
      }

      return null;
    });
  }
}
