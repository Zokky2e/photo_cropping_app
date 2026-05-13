import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1100, 720),
    minimumSize: Size(800, 560),
    center: true,
    title: 'Wallet Padder',
    backgroundColor: Color(0xFF0E0E16),
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: WalletPadderApp()));
}

class WalletPadderApp extends StatelessWidget {
  const WalletPadderApp({super.key});

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
