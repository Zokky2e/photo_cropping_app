import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_image_processor/providers/images_provider.dart';
import 'package:wallet_image_processor/providers/settings_provider.dart';
import 'package:wallet_image_processor/services/settings_window_manager.dart';

class MethodChannelHandler {
  static void init(ProviderContainer container) {
    final channel = WindowMethodChannel(
      'settings_channel',
      mode: ChannelMode.unidirectional,
    );
    print("creating method handler");
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
}
