class AppConfig {
  AppConfig._();

  /// API Base URL passed via `--dart-define=API_URL=...`
  /// Defaults to the production URL.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://job.sutainbuyant.com/api/v1',
  );

  static const String appName = 'E-Commerce App';
}
