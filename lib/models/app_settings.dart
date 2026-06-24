enum QuoteStyle { anime, inspirational, both }

class AppSettings {
  final int refreshIntervalMinutes;
  final QuoteStyle quoteStyle;
  final List<String> userImagePaths;

  const AppSettings({
    this.refreshIntervalMinutes = 30,
    this.quoteStyle = QuoteStyle.both,
    this.userImagePaths = const [],
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        refreshIntervalMinutes: json['refreshIntervalMinutes'] as int? ?? 30,
        quoteStyle: QuoteStyle.values.firstWhere(
          (e) => e.name == (json['quoteStyle'] as String? ?? 'both'),
          orElse: () => QuoteStyle.both,
        ),
        userImagePaths: (json['userImagePaths'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'refreshIntervalMinutes': refreshIntervalMinutes,
        'quoteStyle': quoteStyle.name,
        'userImagePaths': userImagePaths,
      };

  AppSettings copyWith({
    int? refreshIntervalMinutes,
    QuoteStyle? quoteStyle,
    List<String>? userImagePaths,
  }) =>
      AppSettings(
        refreshIntervalMinutes:
            refreshIntervalMinutes ?? this.refreshIntervalMinutes,
        quoteStyle: quoteStyle ?? this.quoteStyle,
        userImagePaths: userImagePaths ?? this.userImagePaths,
      );
}
