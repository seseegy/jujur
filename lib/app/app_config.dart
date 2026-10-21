/// Build-time application information.
class AppConfig {
  const AppConfig({this.appVersion = const String.fromEnvironment('JUJUR_VERSION', defaultValue: '1.0.0')});

  final String appVersion;

  static const appName = 'Jujur';
}
