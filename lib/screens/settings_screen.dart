import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:my_desktop_app/services/settings_window_manager.dart';
import 'package:my_desktop_app/widgets/settings_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsWindowPage extends StatefulWidget {
  const SettingsWindowPage({super.key});

  @override
  State<SettingsWindowPage> createState() => _SettingsWindowPageState();
}

class _SettingsWindowPageState extends State<SettingsWindowPage>
    with WindowListener {
  @override
  void initState() {
    print("creating settings window page");
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) async {
    if (eventName == 'close') {
      print("closing window");
      final prefs = await SharedPreferences.getInstance();

      final bounds = await windowManager.getBounds();

      await prefs.setDouble('settings_x', bounds.left);
      await prefs.setDouble('settings_y', bounds.top);
      await prefs.setDouble('settings_w', bounds.width);
      await prefs.setDouble('settings_h', bounds.height);

      SettingsWindow.clearReference();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.transparent,
      child: SafeArea(child: Center(child: SettingsPanel())),
    );
  }
}
