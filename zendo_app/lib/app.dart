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
              return TaskDetailPage(task: extra as Task);
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
