import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import 'models/task.dart';
import 'providers/auth_model.dart';
import 'providers/task_model.dart';
import 'providers/settings_model.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/auth/sign_up_page.dart';
import 'screens/home/home_page.dart';
import 'screens/account/account_page.dart';
import 'screens/focus/focus_page.dart';
import 'screens/calendar/calendar_page.dart';

import 'screens/tasks/category_detail_page.dart';
import 'screens/splash/splash_page.dart';

/// ZenDo App - Main Application Widget
/// Cấu hình routing, state management và theme
class ZendoApp extends StatelessWidget {
  const ZendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(
          create: (_) {
            final taskModel = TaskModel();
            // Initialize với Supabase thay vì load demo data
            taskModel.initialize();
            return taskModel;
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

        // Task Detail Routes (sẽ thêm sau)
        GoRoute(
          path: '/task/:taskId',
          name: 'taskDetail',
          builder: (context, state) {
            final taskId = state.pathParameters['taskId']!;
            return TaskDetailPage(taskId: taskId);
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
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigate based on index
          switch (index) {
            case 0:
              context.goNamed('home');
              break;
            case 1:
              context.goNamed('calendar');
              break;
            case 2:
              context.goNamed('focus');
              break;
            case 3:
              context.goNamed('account');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

/// Task Detail Page (placeholder - sẽ implement sau)
class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Task')),
      body: Center(child: Text('Task ID: $taskId')),
    );
  }
}
