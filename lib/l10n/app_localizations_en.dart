// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ScreenTime';

  @override
  String get setupDescription =>
      'Counts how long your screen has been on since your last unlock, shown as a persistent notification.';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get resetsEachUnlock => 'Resets each time you unlock';

  @override
  String get notificationPreview => 'NOTIFICATION PREVIEW';

  @override
  String get batteryWarning => 'Android may pause the timer to save battery.';

  @override
  String get keepRunning => 'Keep running';
}
