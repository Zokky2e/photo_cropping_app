import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/providers/images_provider.dart';
import 'package:my_desktop_app/providers/settings_provider.dart';
import 'package:my_desktop_app/screens/settings_screen.dart';
import 'package:my_desktop_app/services/method_channel_handler.dart';
import 'package:my_desktop_app/services/settings_window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'screens/home_screen.dart';

late final ProviderContainer container;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  container = ProviderContainer();
  final windowController = await WindowController.fromCurrentEngine();
  final arguments = windowController.arguments;
  // CHILD WINDOW
  if (args.isNotEmpty) {
    final decodedArgs = jsonDecode(arguments);

    if (decodedArgs['window'] == 'settings') {
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow(
        const WindowOptions(
          titleBarStyle: TitleBarStyle.hidden,
          backgroundColor: Colors.transparent,
        ),
        () async {
          final prefs = await SharedPreferences.getInstance();

          final x = prefs.getDouble(SettingsWindow.xKey) ?? 300;
          final y = prefs.getDouble(SettingsWindow.yKey) ?? 200;
          final w = prefs.getDouble(SettingsWindow.wKey) ?? 500;
          final h = prefs.getDouble(SettingsWindow.hKey) ?? 700;
          await windowManager.setPosition(Offset(x, y));
          await windowManager.setSize(Size(w, h));
          await windowManager.setTitle("Settings");
        },
      );

      runApp(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.transparent,
              canvasColor: Colors.transparent,
            ),
            home: const SettingsWindowPage(),
          ),
        ),
      );
    }

    return;
  }

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1100, 720),
    minimumSize: Size(800, 560),
    center: true,
    title: 'Wallet Padder',
    backgroundColor: Color(0xFF0E0E16),
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  SettingsWindow.create();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WalletPadderApp(),
    ),
  );
}

class WalletPadderApp extends ConsumerStatefulWidget {
  const WalletPadderApp({super.key});

  @override
  ConsumerState<WalletPadderApp> createState() => _WalletPadderAppState();
}

class _WalletPadderAppState extends ConsumerState<WalletPadderApp> {
  @override
  void initState() {
    super.initState();
    //MethodChannelHandler.init(container);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Padder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9FFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF0E0E16),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
