import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/themes/light_theme.dart';
import 'package:ess_mobile/themes/dark_theme.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/providers/language_provider.dart';
import 'package:ess_mobile/providers/theme_provider.dart';
import 'package:ess_mobile/views/splash/splash_screen.dart';
import 'package:ess_mobile/views/auth/login_screen.dart';
import 'package:ess_mobile/views/dashboard/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    globals.platform = Theme.of(context).platform;

    return Consumer<ThemeProvider>(
      builder: (_, themeProviderRef, __) {
        return Consumer<LanguageProvider>(
          builder: (_, languageProviderRef, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: languageProviderRef.appLocale,
              supportedLocales: [
                Locale('en', 'US'),
                Locale('zh', 'CN'),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                FormBuilderLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode ||
                      supportedLocale.countryCode == locale?.countryCode) {
                    return supportedLocale;
                  }
                }

                return supportedLocales.first;
              },
              title: 'Employee Self Service (ESS) Application',
              routes: Routes.routes,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeProviderRef.isDarkModeOn
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: Consumer<AuthProvider>(
                builder: (_, authProviderRef, __) {
                  globals.appAuth = authProviderRef.auth;

                  switch (authProviderRef.status) {
                    case AppStatus.Uninitialized:
                      //return SplashScreen();

                    case AppStatus.Registered:
                    case AppStatus.Unregistered:
                    case AppStatus.Unauthenticated:
                      FlutterNativeSplash.remove();
                      return LoginScreen();

                    case AppStatus.Authenticated:
                      FlutterNativeSplash.remove();
                      return DashboardScreen();

                    default:
                      return Scaffold(body: AppLoading());
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
