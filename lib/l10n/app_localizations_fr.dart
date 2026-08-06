// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ScreenTime';

  @override
  String get setupDescription =>
      'Mesure le temps d\'écran depuis votre dernier déverrouillage, affiché sous forme de notification persistante.';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get resetsEachUnlock => 'Réinitialise à chaque déverrouillage';

  @override
  String get notificationPreview => 'APERÇU DE LA NOTIFICATION';

  @override
  String get batteryWarning =>
      'Android peut mettre le minuteur en pause pour économiser la batterie.';

  @override
  String get keepRunning => 'Continuer';
}
