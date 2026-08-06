// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ScreenTime';

  @override
  String get setupDescription =>
      'Cuenta el tiempo que tu pantalla ha estado encendida desde tu último desbloqueo, mostrado como una notificación persistente.';

  @override
  String get allowNotifications => 'Permitir notificaciones';

  @override
  String get resetsEachUnlock => 'Se reinicia cada vez que desbloqueas';

  @override
  String get notificationPreview => 'VISTA PREVIA DE NOTIFICACIÓN';

  @override
  String get batteryWarning =>
      'Android puede pausar el temporizador para ahorrar batería.';

  @override
  String get keepRunning => 'Continuar';
}
