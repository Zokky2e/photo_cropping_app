import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:my_desktop_app/services/settings_window_manager.dart';
import 'package:my_desktop_app/widgets/settings_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsWindowPage extends StatefulWidget {
  final String mainWindowId;
  const SettingsWindowPage({super.key, required this.mainWindowId});

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
    _registerMethodHandler();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _registerMethodHandler() async {
    final controller = await WindowController.fromCurrentEngine();
    await controller.setWindowMethodHandler((call) async {
      switch (call.method) {
        case 'set_frame':
          final data = call.arguments;
          await windowManager.setPosition(
            Offset(data['x'] as double, data['y'] as double),
          );
          await windowManager.setSize(
            Size(data['w'] as double, data['h'] as double),
          );
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(child: SettingsPanel(mainWindowId: widget.mainWindowId)),
      ),
    );
  }
}
