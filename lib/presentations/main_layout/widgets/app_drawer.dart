import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../cubits/theme_cubit/theme_cubit.dart';


class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final String appVersion;
  final void Function() onSignOut;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.appVersion,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryPurple, AppColors.lightPurple],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset('assets/logo/no_bg_logo.png'),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FireTask',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your tasks',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          context.watch<ThemeCubit>().state == ThemeMode.dark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      value:
                          context.watch<ThemeCubit>().state == ThemeMode.dark,
                      onChanged: (bool isDark) {
                        context.read<ThemeCubit>().toggleTheme(isDark);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.logout_outlined,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onSignOut.call();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                appVersion,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
