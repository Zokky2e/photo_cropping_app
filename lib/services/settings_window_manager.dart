import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWindow {
  static WindowController? _controller;

  static const _xKey = 'settings_x';
  static const _yKey = 'settings_y';
  static const _wKey = 'settings_w';
  static const _hKey = 'settings_h';

  static Future<bool> _isAlive() async {
    if (_controller == null) return false;

    try {
      // any lightweight call works
      await _controller!.setTitle('ping');
      return true;
    } catch (_) {
      _controller = null;
      return false;
    }
  }

  static Future<void> toggle() async {
    if (await _isAlive()) {
      try {
        await _controller!.close();
      } catch (e) {
        // Window was closed externally → cleanup stale controller
      }
      _controller = null;
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final x = prefs.getDouble(_xKey) ?? 300;
    final y = prefs.getDouble(_yKey) ?? 200;
    final w = prefs.getDouble(_wKey) ?? 500;
    final h = prefs.getDouble(_hKey) ?? 700;

    final window = await DesktopMultiWindow.createWindow(
      jsonEncode({'window': 'settings'}),
    );

    _controller = window;

    await window.setFrame(Offset(x, y) & Size(w, h));

    await window.setTitle('Settings');

    await window.show();
  }

  static void clearReference() {
    _controller = null;
  }
}
