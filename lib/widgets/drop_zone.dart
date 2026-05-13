import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class DropZone extends StatefulWidget {
  final Widget child;
  final void Function(List<String> paths) onFilesDropped;

  const DropZone({
    required this.child,
    required this.onFilesDropped,
    super.key,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        final paths = details.files.map((f) => f.path).toList();
        widget.onFilesDropped(paths);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragging ? const Color(0xFF6B9FFF) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: _isDragging
              ? const Color(0xFF6B9FFF).withOpacity(0.06)
              : Colors.transparent,
        ),
        child: widget.child,
      ),
    );
  }
}
