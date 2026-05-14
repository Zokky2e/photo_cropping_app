import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsWindow {
  static WindowController? _controller;

  static const xKey = 'settings_x';
  static const yKey = 'settings_y';
  static const wKey = 'settings_w';
  static const hKey = 'settings_h';

  static Future<bool> _isAlive() async {
    return _controller != null;
  }

  static Future<void> toggle() async {
    if (await _isAlive()) {
      try {
        await windowManager.close();
      } catch (_) {}
      _controller = null;
      return;
    }

    final controller = await WindowController.create(
      WindowConfiguration(arguments: jsonEncode({'window': 'settings'})),
    );

    _controller = controller;

    // SHOW WINDOW
    await controller.show();
  }

  static void clearReference() {
    _controller = null;
  }
}
