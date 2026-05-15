import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  Future<void> _closeAll() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WinButton(
          color: const Color(0xFFFFBD2E),
          icon: Icons.remove,
          onTap: () => windowManager.minimize(),
        ),
        const SizedBox(width: 8),
        _WinButton(
          color: const Color(0xFF28CA42),
          icon: Icons.crop_square,
          onTap: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        const SizedBox(width: 8),
        _WinButton(
          color: const Color(0xFFFF5F57),
          icon: Icons.close,
          onTap: () => _closeAll(),
        ),
      ],
    );
  }
}

class _WinButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _WinButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, size: 12, color: Colors.black54),
        ),
      ),
    );
  }
}
