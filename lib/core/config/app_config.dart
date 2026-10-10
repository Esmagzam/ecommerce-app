class AppConfig {
  AppConfig._();

  /// `--dart-define=API_URL=...` замаар дамжуулах API-ийн үндсэн хаяг.
  /// Тодорхойлоогүй тохиолдолд үндсэн production хаягийг ашиглана.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://job.sutainbuyant.com/api/v1',
  );

  static const String appName = 'E-Commerce App';
}
