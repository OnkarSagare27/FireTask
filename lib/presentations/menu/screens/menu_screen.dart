import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../cubits/theme_cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  String _appVersion = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildProfileSection(theme),
              
              const SizedBox(height: 32),
              
              
              _buildSectionHeader('Connect With Me', theme),
              const SizedBox(height: 16),
              _buildSocialLinks(theme),
              
              const SizedBox(height: 32),
              
              
              _buildSectionHeader('Settings', theme),
              const SizedBox(height: 16),
              _buildSettingsSection(theme, isDarkMode),
              
              const SizedBox(height: 32),
              
              
              _buildSectionHeader('About', theme),
              const SizedBox(height: 16),
              _buildAboutSection(theme),
              
              const SizedBox(height: 20),
              
              
              _buildVersionInfo(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple,
            AppColors.lightPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Icons.person,
              size: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Onkar Sagare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flutter Developer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Building amazing mobile experiences',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSocialLinks(ThemeData theme) {
    return Column(
      children: [
        _buildSocialCard(
          svgPath: "assets/icons/linked_in_icon.svg",
          title: 'LinkedIn',
          subtitle: 'Connect with me professionally',
          url: 'https://www.linkedin.com/in/onkar-sagare/',
           color: theme.brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildSocialCard(
          svgPath: "assets/icons/github_icon.svg",
          title: 'GitHub',
          subtitle: 'Check out my projects',
          url: 'https://github.com/OnkarSagare27',
          color: theme.brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSocialCard({
  required String svgPath,
  required String title,
  required String subtitle,
  required String url,
  required Color color,
  required ThemeData theme,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha:0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  svgPath,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha:0.5),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildSettingsSection(ThemeData theme, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Switch between light and dark themes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7),
              ),
            ),
            value: isDarkMode,
            onChanged: (value) {
              context.read<ThemeCubit>().toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:Image.asset('assets/logo/no_bg_logo.png', height: 25,),
              ),
              const SizedBox(width: 12),
              Text(
                'FireTask',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A powerful task management app built with Flutter. Organize your tasks, set priorities, and stay productive with an intuitive and beautiful interface.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Version $_appVersion',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
