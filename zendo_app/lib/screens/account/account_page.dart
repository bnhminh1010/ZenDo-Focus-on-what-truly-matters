import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_model.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'language_page.dart';
import 'help_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    // Responsive padding
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0);
    final bottomPadding = isDesktop ? 80.0 : (isTablet ? 100.0 : 140.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer2<AuthModel, ThemeProvider>(
        builder: (context, authModel, themeProvider, child) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Responsive padding
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Semantics(
                        label: 'Trang tài khoản',
                        child: Text(
                          'Tài khoản',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 40 : 32),

                      // Profile Section
                      Semantics(
                        label: 'Thông tin hồ sơ người dùng',
                        child: GlassContainer(
                          borderRadius: 20,
                          blur: 16,
                          opacity: 0.14, // Đồng nhất opacity
                          padding: EdgeInsets.all(
                            isDesktop ? 32 : (isTablet ? 28 : 24),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Semantics(
                                label: 'Ảnh đại diện người dùng',
                                child: CircleAvatar(
                                  radius: isDesktop ? 40 : (isTablet ? 35 : 30),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  child:
                                      false // authModel không có photoURL
                                      ? ClipOval(
                                          child: Image.network(
                                            '', // Placeholder
                                            width: isDesktop
                                                ? 80
                                                : (isTablet ? 70 : 60),
                                            height: isDesktop
                                                ? 80
                                                : (isTablet ? 70 : 60),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.person,
                                                    size: isDesktop
                                                        ? 40
                                                        : (isTablet ? 35 : 30),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.8),
                                                  );
                                                },
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: isDesktop
                                              ? 40
                                              : (isTablet ? 35 : 30),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.8),
                                        ),
                                ),
                              ),
                              SizedBox(width: isDesktop ? 20 : 16),

                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Semantics(
                                      label:
                                          'Tên người dùng: ${authModel.userName ?? 'Người dùng'}',
                                      child: Text(
                                        authModel.userName ?? 'Người dùng',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: isDesktop ? 8 : 4),
                                    Semantics(
                                      label:
                                          'Email: ${authModel.userEmail ?? 'Chưa có email'}',
                                      child: Text(
                                        authModel.userEmail ?? 'Chưa có email',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.8),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 40 : 32),

                      // Menu Items
                      _buildMenuSection(
                        context,
                        isTablet,
                        isDesktop,
                        themeProvider,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Personal Information
        Semantics(
          label: 'Thông tin cá nhân',
          hint: 'Nhấn để chỉnh sửa thông tin cá nhân',
          child: _buildMenuItem(
            context: context,
            icon: Icons.person_outline,
            title: 'Hồ sơ cá nhân',
            onTap: () => context.pushNamed('profile'),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.notifications_outlined,
          title: 'Thông báo',
          onTap: () => context.pushNamed('notifications'),
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.security_outlined,
          title: 'Bảo mật',
          onTap: () => context.pushNamed('security'),
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.language_outlined,
          title: 'Ngôn ngữ',
          onTap: () => context.pushNamed('language'),
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Notifications
        Semantics(
          label: 'Cài đặt thông báo',
          hint: 'Nhấn để cài đặt thông báo',
          child: _buildMenuItem(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            onTap: () => context.pushNamed('notifications'),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Category Management
        Semantics(
          label: 'Quản lý danh mục',
          hint: 'Nhấn để quản lý danh mục nhiệm vụ',
          child: _buildMenuItem(
            context: context,
            icon: Icons.category_outlined,
            title: 'Quản lý danh mục',
            onTap: () {
              context.pushNamed('categoryManagement');
            },
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Dark Mode Toggle
        Semantics(
          label: 'Chế độ tối',
          hint: 'Bật hoặc tắt chế độ tối',
          child: _buildMenuItemWithSwitch(
            context: context,
            icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Chế độ tối',
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
            },
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Security
        Semantics(
          label: 'Bảo mật',
          hint: 'Nhấn để cài đặt bảo mật',
          child: _buildMenuItem(
            context: context,
            icon: Icons.security_outlined,
            title: 'Bảo mật',
            onTap: () => context.pushNamed('security'),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Language
        Semantics(
          label: 'Ngôn ngữ',
          hint: 'Nhấn để thay đổi ngôn ngữ',
          child: _buildMenuItem(
            context: context,
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            onTap: () => context.pushNamed('language'),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Help
        Semantics(
          label: 'Trợ giúp',
          hint: 'Nhấn để xem trợ giúp',
          child: _buildMenuItem(
            context: context,
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () => context.pushNamed('help'),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // About
        Semantics(
          label: 'Về ứng dụng',
          hint: 'Nhấn để xem thông tin về ứng dụng',
          child: _buildMenuItem(
            context: context,
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            onTap: () => _showAboutDialog(context),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 20),

        // Logout Button
        Semantics(
          label: 'Đăng xuất',
          hint: 'Nhấn để đăng xuất khỏi tài khoản',
          child: _buildLogoutButton(
            context: context,
            authModel: Provider.of<AuthModel>(context, listen: false),
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.14, // Đồng nhất opacity
      padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: isDesktop ? 28 : (isTablet ? 26 : 24),
            ),
            SizedBox(width: isDesktop ? 20 : 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7),
              size: isDesktop ? 20 : 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.14, // Đồng nhất opacity
      padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: isDesktop ? 28 : (isTablet ? 26 : 24),
          ),
          SizedBox(width: isDesktop ? 20 : 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: 24,
            blur: 20,
            opacity: 0.15,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Icon & Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  'ZenDo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Focus on what truly matters',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                // App Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.info_outline,
                        'Phiên bản',
                        '1.0.0',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.apps_outlined,
                        'Ứng dụng',
                        'Quản lý nhiệm vụ và tập trung',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.developer_mode_outlined,
                        'Phát triển bởi',
                        'ZenDo Team',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // GitHub Link Button
                SizedBox(
                  width: double.infinity,
                  child: GlassElevatedButton.icon(
                    onPressed: _launchGitHub,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    icon: const Icon(Icons.code_outlined),
                    label: const Text(
                      'Xem mã nguồn trên GitHub',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Close Button
                GlassTextButton(
                  child: const Text('Đóng'),
                  onPressed: () => Navigator.of(context).pop(),
                  textColor: colorScheme.onSurface.withOpacity(0.85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton({
    required BuildContext context,
    required AuthModel authModel,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.14,
      padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.1),
              Colors.red.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () => _showLogoutDialog(context, authModel),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.red.shade400,
                    size: isDesktop ? 28 : (isTablet ? 26 : 24),
                  ),
                ),
                SizedBox(width: isDesktop ? 20 : 16),
                Expanded(
                  child: Text(
                    'Đăng xuất',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red.shade400.withOpacity(0.7),
                  size: isDesktop ? 20 : 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthModel authModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: 24,
            blur: 20,
            opacity: 0.15,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Xác nhận đăng xuất',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GlassOutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        borderColor: colorScheme.onSurface,
                        textColor: colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Logout Button
                    Expanded(
                      child: GlassElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            await authModel.signOut();
                            context.go('/login');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đăng xuất thất bại. Vui lòng thử lại.',
                                ),
                              ),
                            );
                          }
                        },
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchGitHub() async {
    const url =
        'https://github.com/bnhminh1010/ZenDo-Focus-on-what-truly-matters.git';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

