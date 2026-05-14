import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/settings_provider.dart';
import '../providers/images_provider.dart';
import '../models/settings_model.dart';

// Tracks panel visibility and position across the app session
class SettingsPanelController extends ChangeNotifier {
  Offset _position = const Offset(80, 80);

  Offset get position => _position;

  void moveTo(Offset offset) {
    _position = offset;
    notifyListeners();
  }
}

// Single instance shared across the widget tree
final settingsPanelController = SettingsPanelController();

// ---------------------------------------------------------------------------
// The panel itself
// ---------------------------------------------------------------------------

class SettingsPanel extends ConsumerStatefulWidget {
  const SettingsPanel();

  @override
  ConsumerState<SettingsPanel> createState() => SettingsPanelState();
}

class SettingsPanelState extends ConsumerState<SettingsPanel> {
  void _rebuild() => setState(() {});
  // Local draft state — only applied on Save
  late double _heightPadding;
  late double _widthPadding;
  late int _outputQuality;
  late String _processedPrefix;
  final _processedPrefixController = TextEditingController();

  @override
  void initState() {
    settingsPanelController.addListener(_rebuild);
    super.initState();
    _loadFromSettings(ref.read(settingsProvider));
    _processedPrefixController.text = _processedPrefix;
  }

  @override
  void dispose() {
    settingsPanelController.removeListener(_rebuild);
    super.dispose();
  }

  void _loadFromSettings(ProcessingSettings s) {
    _heightPadding = s.heightPadding;
    _widthPadding = s.widthPadding;
    _outputQuality = s.outputQuality;
    _processedPrefix = s.processedPrefix;
  }

  Future<void> _save() async {
    print("saving...");
    const channel = WindowMethodChannel('settings_channel');

    await channel.invokeMethod('settings_updated', {
      'heightPadding': _heightPadding,
      'widthPadding': _widthPadding,
      'outputQuality': _outputQuality,
      'processedPrefix': _processedPrefix,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Drag the panel by its title bar
      onPanUpdate: (details) {
        settingsPanelController.moveTo(
          settingsPanelController.position + details.delta,
        );
      },
      child: Material(
        elevation: 16,
        color: const Color(0xFF1A1A28),
        child: SizedBox.expand(
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2E2E4E), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title bar (drag handle) ─────────────────────────────
                _TitleBar(
                  onClose: () async {
                    const channel = WindowMethodChannel('settings_channel');

                    await channel.invokeMethod('settings_closed');
                  },
                  onDrag: (details) {
                    settingsPanelController.moveTo(
                      settingsPanelController.position + details.delta,
                    );
                  },
                ),

                // ── Settings body ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Height Padding
                      _SectionLabel('Height Padding'),
                      const SizedBox(height: 4),
                      _SliderRow(
                        label: 'Amount',
                        value: _heightPadding,
                        min: 0.01,
                        max: 0.99,
                        displayValue: '$_heightPadding',
                        onChanged: (v) => setState(() => _heightPadding = v),
                      ),

                      const SizedBox(height: 20),

                      // Width Padding
                      _SectionLabel('Width Padding'),
                      const SizedBox(height: 4),
                      _SliderRow(
                        label: 'Amount',
                        value: _widthPadding,
                        min: 0.01,
                        max: 0.99,
                        displayValue: '$_widthPadding',
                        onChanged: (v) => setState(() => _widthPadding = v),
                      ),

                      const SizedBox(height: 20),

                      // Quality
                      _SectionLabel('Output quality'),
                      const SizedBox(height: 4),
                      _SliderRow(
                        label: 'JPEG quality',
                        value: _outputQuality.toDouble(),
                        min: 50,
                        max: 100,
                        displayValue: '$_outputQuality',
                        onChanged: (v) =>
                            setState(() => _outputQuality = v.round()),
                      ),

                      const SizedBox(height: 24),

                      // Processed Prefix
                      _SectionLabel('Image name prefix'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _processedPrefixController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Saved Image Prefix",
                        ),
                        onChanged: (v) => setState(() => _processedPrefix = v),
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6B9FFF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save settings',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _TitleBar extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<DragUpdateDetails> onDrag;
  const _TitleBar({required this.onClose, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onDrag,
      child: DragToMoveArea(
        child: Container(
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF13131C),
            border: Border(bottom: BorderSide(color: Color(0xFF2E2E4E))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 15,
                color: Color(0xFF6B9FFF),
              ),
              const SizedBox(width: 8),
              const Text(
                'Processing settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF666677),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF555577),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFFCCCCDD), fontSize: 13),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                color: Color(0xFF6B9FFF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6B9FFF),
            inactiveTrackColor: const Color(0xFF2E2E4E),
            thumbColor: const Color(0xFF6B9FFF),
            overlayColor: const Color(0xFF6B9FFF22),
            trackHeight: 3,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
