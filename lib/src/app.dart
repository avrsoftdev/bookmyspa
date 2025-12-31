import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/di.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/locale_cubit.dart';
import 'package:bookmyspa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl.get<CartBloc>()),
            BlocProvider(create: (context) => sl.get<ThemeCubit>()),
            BlocProvider(create: (context) => sl.get<LocaleCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp(
                    title:
                        AppLocalizations.of(context)?.appTitle ?? 'BookMySpa',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeMode,
                    locale: locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    themeAnimationDuration: const Duration(milliseconds: 250),
                    themeAnimationCurve: Curves.easeInOut,
                    onGenerateRoute: AppRouter.onGenerateRoute,
                    initialRoute: '/',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
