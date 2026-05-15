import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsWindow {
  static WindowController? _controller;
  static bool _isVisible = false;

  static const xKey = 'settings_x';
  static const yKey = 'settings_y';
  static const wKey = 'settings_w';
  static const hKey = 'settings_h';

  static Future<void> create() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(xKey) ?? 300;
    final y = prefs.getDouble(yKey) ?? 200;
    final w = prefs.getDouble(wKey) ?? 500;
    final h = prefs.getDouble(hKey) ?? 700;
    final window = await WindowController.create(
      WindowConfiguration(
        hiddenAtLaunch: true,
        arguments: jsonEncode({'window': 'settings'}),
      ),
    );

    _controller = window;
    _controller!.hide();
  }

  static Future<void> toggle() async {
    if (_controller == null) return;
    if (_isVisible) {
      await _controller!.hide();
      _isVisible = false;
    } else {
      await _controller!.show();
      _isVisible = true;
    }
  }

  static Future<void> hide() async {
    if (_controller == null) return;
    await _controller!.hide();
    _isVisible = false;
  }

  static void clearReference() {
    _controller = null;
  }
}
