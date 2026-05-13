class ProcessingSettings {
  final double heightPadding;
  final double widthPadding;
  final int outputQuality;
  final String processedPrefix;

  const ProcessingSettings({
    this.heightPadding = 0.5,
    this.widthPadding = 0.6667,
    this.outputQuality = 95,
    this.processedPrefix = "wallet",
  });

  ProcessingSettings copyWith({
    double? heightPadding,
    double? widthPadding,
    int? outputQuality,
    String? processedPrefix,
  }) {
    return ProcessingSettings(
      heightPadding: heightPadding ?? this.heightPadding,
      widthPadding: widthPadding ?? this.widthPadding,
      outputQuality: outputQuality ?? this.outputQuality,
      processedPrefix: processedPrefix ?? this.processedPrefix,
    );
  }
}
