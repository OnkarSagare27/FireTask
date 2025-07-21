import 'package:firebase_core/firebase_core.dart';
import 'package:firetask/bloc/tasks_bloc.dart';
import 'package:firetask/cubits/theme_cubit/theme_cubit.dart';
import 'package:firetask/data/repositories/task_repository.dart';
import 'package:firetask/presentations/menu/screens/menu_screen.dart';
import 'package:firetask/presentations/welcome/screens/welcome_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_themes/app_themes.dart';
import 'core/constants/firebase_options.dart';
import 'presentations/auth/bloc/auth_bloc.dart';
import 'presentations/auth/repositories/auth_repository.dart';
import 'presentations/auth/screens/auth_screen.dart';
import 'presentations/main_layout/screens/main_layout_screen.dart';

void main() async {
  await dotenv.load(fileName: "lib/core/constants/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
        BlocProvider(create:(context) => TasksBloc(taskRepository: TaskRepository()),),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
         
        builder: (context, themeMode) {
          final brightness = View.of(
            context,
          ).platformDispatcher.platformBrightness;
          final isDark = themeMode == ThemeMode.system
              ? brightness == Brightness.dark
              : themeMode == ThemeMode.dark;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
          );
          return MaterialApp(
            title: 'FireTask',
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routes: {
              "/welcome": (context) => WelcomeScreen(),
              "/auth": (context) => AuthScreen(),
              "/home": (context) => MainLayoutScreen(),
              "/menu": (context) => MenuScreen()
            },
            initialRoute: AuthRepository().currentUser != null
                ? "/home"
                : "/welcome",
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
