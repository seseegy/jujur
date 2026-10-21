import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_failure.dart';
import '../core/notifications/reminder_sync.dart';
import 'app_config.dart';
import 'providers.dart';
import 'router.dart';
import 'startup_error_app.dart';
import 'theme/app_theme.dart';

class JujurApp extends ConsumerStatefulWidget {
  const JujurApp({super.key});

  @override
  ConsumerState<JujurApp> createState() => _JujurAppState();
}

class _JujurAppState extends ConsumerState<JujurApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncReminders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-plan reminders on resume: covers timezone changes, date changes and
    // permission changes made in system settings.
    if (state == AppLifecycleState.resumed) _syncReminders();
  }

  Future<void> _syncReminders() async {
    try {
      await ref.read(reminderSyncProvider)();
    } on Object catch (e) {
      // Reminders are optional; core features keep working without them.
      logError('startup reminders', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(prefsProvider.select((p) => p.themeMode));
    final prefs = ref.watch(preferencesProvider);
    if (!prefs.hasValue) {
      // Settings load from the local database in milliseconds; avoid flashing
      // the wrong screen or theme before they are known.
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: prefs.hasError
            ? StartupErrorApp(error: prefs.error!)
            : const Scaffold(body: SizedBox.expand()),
      );
    }
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 150),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
