import 'package:firetask/presentations/main_layout/widgets/app_drawer.dart';
import 'package:firetask/presentations/tasks/screens/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../bloc/tasks_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../calendar/screens/calendar_screen.dart';

import '../../widgets/confirmation_dialog.dart';
import '../../widgets/task_form_dialog.dart';
import '../widgets/animated_circles.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late PageController _pageController;
  String _appVersion = '';
  late final TextEditingController _textEditingController;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _pageController = PageController();

    _screens.addAll([
      TasksScreen(searchController: _textEditingController),
      CalendarScreen(searchController: _textEditingController),
    ]);

    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );

    HapticFeedback.lightImpact();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
    
      Navigator.of(context).pushReplacementNamed('/auth');
    }
      },
      child: Scaffold(
              resizeToAvoidBottomInset: true,

        drawer: AppDrawer(
          isDarkMode: isDarkMode,
          appVersion: _appVersion,
          onSignOut: () {
            ConfirmationDialog.show(
              context: context,
              title: 'Sign Out',
              message: 'Are you sure you want to sign out?',
              confirmText: 'Sign Out',
              cancelText: 'Cancel',
              isDestructive: true,
              onConfirm: () {
                context.read<AuthBloc>().add(AuthLogOutRequested());
              },
            );
          },
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryPurple, AppColors.lightPurple],
                  ),
                ),
              ),

              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CirclesPainter(_animationController.value),
                    size: Size.infinite,
                  );
                },
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) => GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/drawer_icon.svg",
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 30),

                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  hintText: 'Search tasks...',
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 30),

                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 20,
                              ),
                              onPressed: () =>       Navigator.of(context).pushNamed('/menu')
,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat("dd MMM, yyyy ").format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _currentIndex == 0 ? 'My tasks' : 'Calendar',
                              key: ValueKey(_currentIndex),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),

        floatingActionButton: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () async {
              HapticFeedback.mediumImpact();

              final result = await showDialog<Task>(
                context: context,
                builder: (context) => const TaskFormDialog(),
              );

              if (result != null && context.mounted) {
                context.read<TasksBloc>().add(AddTask(result));
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1, color: Theme.of(context).dividerColor),
            ),
          ),
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDarkMode
                ? AppColors.darkCardBackground
                : Colors.white,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.format_list_bulleted_rounded, 0),
                activeIcon: _buildNavIcon(
                  Icons.format_list_bulleted_rounded,
                  0,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.calendar_today_outlined, 1),
                activeIcon: _buildNavIcon(Icons.calendar_today_outlined, 1),
                label: 'Calendar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: isSelected
          ? BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Icon(
        icon,
        size: 24,
        color: isSelected
            ? AppColors.primaryPurple
            : Theme.of(context).iconTheme.color?.withOpacity(0.6),
      ),
    );
  }
}
