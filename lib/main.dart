import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopflow/settings/viewmodel/settings_viewmodel.dart';

import 'core/constants/app_colors.dart';
import 'core/local/hive_service.dart';
import 'core/network/view/network_wrapper.dart';
import 'core/providers/app_providers.dart';
import 'core/routes/app_routes.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await HiveService.initialize();

  await _initializeNotifications();
}

Future<void> _initializeNotifications() async {
  final notificationService = NotificationService();

  await notificationService.initializeLocalNotifications();

  notificationService.listenTokenRefresh();

  notificationService.listenForegroundMessages();

  notificationService.listenNotificationTap();

  await _handleInitialNotification(
    notificationService,
  );

}

Future<void> _handleInitialNotification(
  NotificationService notificationService,
) async {
  final message =
      await notificationService.getInitialMessage();

  if (message == null) {
    return;
  }


}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<SettingsViewModel>(
        builder: (
          context,
          settingsViewModel,
          child,
        ) {
          return MaterialApp(
            title: 'ShopFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsViewModel.darkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,

            home: const SplashScreen(),

            onGenerateRoute: AppRoutes.generateRoute,

            builder: (
              context,
              child,
            ) {
              return NetworkWrapper(
                child: child ??
                    const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}