import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';

class SettingsNotifier extends StateNotifier<ProcessingSettings> {
  SettingsNotifier() : super(const ProcessingSettings());

  void updateSettings({
    required double heightPadding,
    required double widthPadding,
    required int outputQuality,
    required String processedPrefix,
  }) {
    state = state.copyWith(
      heightPadding: heightPadding,
      widthPadding: widthPadding,
      outputQuality: outputQuality,
      processedPrefix: processedPrefix,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ProcessingSettings>((ref) {
      return SettingsNotifier();
    });
