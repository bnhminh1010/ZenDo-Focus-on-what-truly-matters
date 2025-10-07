import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_model.dart';
import '../../providers/theme_provider.dart';
// ignore: unused_import
import '../../theme.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'language_page.dart';
import 'help_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer2<AuthModel, ThemeProvider>(
        builder: (context, authModel, themeProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Tài khoản',
                    style: theme.textTheme.titleLarge,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Profile Section - simplified
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authModel.userName ?? 'User',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authModel.userEmail ?? 'user@example.com',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Menu Items - clean list design
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.notifications_outlined,
                    title: 'Thông báo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItemWithSwitch(
                    context: context,
                    icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    title: 'Chế độ tối',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.setDarkMode(value);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.security_outlined,
                    title: 'Bảo mật',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecurityPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.language_outlined,
                    title: 'Ngôn ngữ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguagePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Trợ giúp',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'Về ứng dụng',
                    onTap: () => _showAboutDialog(context),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _showLogoutDialog(context, authModel);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Đăng xuất',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          color: colorScheme.onSurface,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMenuItemWithSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          color: colorScheme.onSurface,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthModel authModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Xác nhận đăng xuất',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authModel.signOut();
              },
              child: Text(
                'Đăng xuất',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Về ZenDo',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZenDo - Focus on what truly matters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phiên bản: 1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ZenDo là nền tảng quản lý cuộc sống thông minh, giúp bạn tập trung vào những việc quan trọng nhất bằng cách kết hợp AI để nhập liệu tự nhiên, sắp xếp ưu tiên và phân tích thói quen.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _launchGitHub(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Xem mã nguồn trên GitHub',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Đóng',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _launchGitHub() async {
    const url = 'https://github.com/bnhminh1010/ZenDo-Focus-on-what-truly-matters.git';
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}