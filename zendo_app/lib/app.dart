/*
 * Tên: app.dart
 * Tác dụng: Khởi tạo ứng dụng ZenDo với MultiProvider, cấu hình theme và GoRouter.
 * Khi nào dùng: File chính của app, được import bởi main.dart để thiết lập routing và state.
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import 'models/task.dart';
import 'providers/auth_model.dart';
import 'providers/task_model.dart';
import 'providers/category_model.dart';
import 'providers/focus_session_model.dart';
import 'providers/settings_model.dart';
import 'providers/theme_provider.dart';
import 'providers/google_signin_provider.dart';
import 'providers/github_signin_provider.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/auth/sign_up_page.dart';
import 'screens/home/home_page.dart';
import 'screens/account/account_page.dart';
import 'screens/focus/focus_page.dart';
import 'screens/calendar/calendar_page.dart';
import 'screens/ai/ai_chat_page.dart';

import 'screens/tasks/task_list_page.dart';
import 'screens/tasks/task_detail_page.dart';
import 'screens/tasks/category_detail_page.dart';
import 'screens/categories/categories_list_page.dart';
import 'screens/categories/category_management_page.dart';
import 'screens/splash/splash_page.dart';
import 'screens/account/profile_page.dart';
import 'screens/account/notifications_page.dart';
import 'screens/account/security_page.dart';
import 'screens/account/language_page.dart';
import 'screens/account/help_page.dart';

import 'widgets/glass_container.dart';

/// ZenDo App - Main Application Widget
/// Cấu hình routing, state management và theme
class ZendoApp extends StatelessWidget {
  const ZendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        ChangeNotifierProvider(create: (_) => GitHubSignInProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final taskModel = TaskModel();
            // Initialize với Supabase thay vì load demo data
            taskModel.initialize();
            return taskModel;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final categoryModel = CategoryModel();
            categoryModel.loadCategories();
            return categoryModel;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final focusSessionModel = FocusSessionModel();
            focusSessionModel.loadFocusSessions();
            return focusSessionModel;
          },
        ),
        ChangeNotifierProvider(create: (_) => SettingsModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthModel, ThemeProvider>(
        builder: (context, authModel, themeProvider, child) {
          return MaterialApp.router(
            title: 'ZenDo - Focus on what truly matters',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Router Configuration
            routerConfig: _createRouter(authModel),
          );
        },
      ),
    );
  }

  /// Tạo GoRouter với authentication guard
  GoRouter _createRouter(AuthModel authModel) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = authModel.isAuthenticated;
        final isLoggingIn =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        final isSplash = state.matchedLocation == '/splash';

        // Nếu đang ở splash, cho phép
        if (isSplash) return null;

        // Nếu chưa đăng nhập và không ở trang login/register
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // Nếu đã đăng nhập và đang ở trang login/register
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null; // Không redirect
      },
      routes: [
        // Splash Screen
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const SignUpPage(),
        ),

        // Main App Routes với Bottom Navigation
        ShellRoute(
          builder: (context, state, child) {
            return MainNavigationWrapper(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/calendar',
              name: 'calendar',
              builder: (context, state) => const CalendarPage(),
            ),
            GoRoute(
              path: '/focus',
              name: 'focus',
              builder: (context, state) => const FocusPage(),
            ),
            GoRoute(
              path: '/account',
              name: 'account',
              builder: (context, state) => const AccountPage(),
            ),
          ],
        ),

        // Task List Route
        GoRoute(
          path: '/tasks',
          name: 'tasks',
          builder: (context, state) => const TaskListPage(),
        ),

        // Categories List Route
        GoRoute(
          path: '/categories',
          name: 'categories',
          builder: (context, state) => const CategoriesListPage(),
        ),

        // Task Detail Routes
        GoRoute(
          path: '/task/:taskId',
          name: 'taskDetail',
          builder: (context, state) {
            final taskId = state.pathParameters['taskId']!;
            final extra = state.extra as Task?;

            if (extra != null) {
              return TaskDetailPage(task: extra);
            }

            // Fallback: tìm task từ TaskModel nếu không có extra
            return Consumer<TaskModel>(
              builder: (context, taskModel, child) {
                final task = taskModel.tasks.firstWhere(
                  (t) => t.id == taskId,
                  orElse: () => throw Exception('Task not found'),
                );
                return TaskDetailPage(task: task);
              },
            );
          },
        ),

        // Category Detail Route
        GoRoute(
          path: '/category/:categoryName',
          name: 'categoryDetail',
          builder: (context, state) {
            final categoryName = state.pathParameters['categoryName']!;
            final extra = state.extra as Map<String, dynamic>?;

            return CategoryDetailPage(
              categoryName: categoryName,
              categoryIcon: extra?['icon'] ?? Icons.folder,
              categoryColor: extra?['color'] ?? Colors.blue,
              category: extra?['category'] ?? TaskCategory.other,
            );
          },
        ),

        // Category Management Route
        GoRoute(
          path: '/category-management',
          name: 'categoryManagement',
          builder: (context, state) => const CategoryManagementPage(),
        ),

        // AI Chat Route
        GoRoute(
          path: '/ai-chat',
          name: 'aiChat',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return AIChatPage(extra: extra);
          },
        ),

        // Account sub-pages
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/security',
          name: 'security',
          builder: (context, state) => const SecurityPage(),
        ),
        GoRoute(
          path: '/language',
          name: 'language',
          builder: (context, state) => const LanguagePage(),
        ),
        GoRoute(
          path: '/help',
          name: 'help',
          builder: (context, state) => const HelpPage(),
        ),
      ],
    );
  }
}

/// Wrapper cho Main Navigation với Bottom Navigation Bar
class MainNavigationWrapper extends StatefulWidget {
  final Widget child;

  const MainNavigationWrapper({super.key, required this.child});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cho phép body vẽ phía sau để tạo cảm giác nổi thực sự
      extendBody: true,
      body: Stack(
        children: [
          // Nội dung chính
          widget.child,

          // Thanh điều hướng popup nổi thực sự
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: GlassContainer(
              borderRadius: 28,
              // Glass morphism effect
              blur: 3,
              opacity: 0.00,
              pill: true,
              highlightEdge: true,
              innerShadow: false,
              // Bóng ngoài để tạo hiệu ứng nổi
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
              // Gradient nhẹ
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface.withOpacity(0.06),
                  Theme.of(context).colorScheme.surface.withOpacity(0.12),
                ],
              ),
              // Viền mỏng
              border: Border.fromBorderSide(
                BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withOpacity(0.22),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Trang chủ',
                    index: 0,
                    onTap: () => context.goNamed('home'),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today,
                    label: 'Lịch',
                    index: 1,
                    onTap: () => context.goNamed('calendar'),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.timer_outlined,
                    activeIcon: Icons.timer,
                    label: 'Focus',
                    index: 2,
                    onTap: () => context.goNamed('focus'),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Tài khoản',
                    index: 3,
                    onTap: () => context.goNamed('account'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = _currentIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
