import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_model.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _autoLockEnabled = true;
  String _autoLockTime = '5 phút';

  final List<String> _autoLockOptions = [
    'Ngay lập tức',
    '1 phút',
    '5 phút',
    '15 phút',
    '30 phút',
    'Không bao giờ',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Bảo mật',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Authentication Section
            _buildSectionHeader('Xác thực'),
            const SizedBox(height: 16),
            _buildActionTile(
              title: 'Đổi mật khẩu',
              subtitle: 'Cập nhật mật khẩu của bạn',
              icon: Icons.lock_outline,
              onTap: _showChangePasswordDialog,
            ),
            _buildSwitchTile(
              title: 'Xác thực sinh trắc học',
              subtitle: 'Sử dụng vân tay hoặc Face ID',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
              icon: Icons.fingerprint_outlined,
            ),
            _buildSwitchTile(
              title: 'Xác thực 2 bước',
              subtitle: 'Bảo mật bổ sung cho tài khoản',
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  _twoFactorEnabled = value;
                });
              },
              icon: Icons.security_outlined,
            ),

            const SizedBox(height: 32),

            // App Lock Section
            _buildSectionHeader('Khóa ứng dụng'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Tự động khóa',
              subtitle: 'Khóa ứng dụng khi không sử dụng',
              value: _autoLockEnabled,
              onChanged: (value) {
                setState(() {
                  _autoLockEnabled = value;
                });
              },
              icon: Icons.lock_clock_outlined,
            ),
            if (_autoLockEnabled)
              _buildSelectionTile(
                title: 'Thời gian tự động khóa',
                subtitle: _autoLockTime,
                icon: Icons.timer_outlined,
                onTap: _showAutoLockOptions,
              ),

            const SizedBox(height: 32),

            // Privacy Section
            _buildSectionHeader('Quyền riêng tư'),
            const SizedBox(height: 16),
            _buildActionTile(
              title: 'Quyền ứng dụng',
              subtitle: 'Quản lý quyền truy cập',
              icon: Icons.admin_panel_settings_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            _buildActionTile(
              title: 'Dữ liệu & quyền riêng tư',
              subtitle: 'Xem và quản lý dữ liệu cá nhân',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),

            const SizedBox(height: 32),

            // Account Management Section
            _buildSectionHeader('Quản lý tài khoản'),
            const SizedBox(height: 16),
            _buildActionTile(
              title: 'Phiên đăng nhập',
              subtitle: 'Quản lý các thiết bị đã đăng nhập',
              icon: Icons.devices_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            _buildActionTile(
              title: 'Xuất dữ liệu',
              subtitle: 'Tải xuống dữ liệu cá nhân',
              icon: Icons.download_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),

            const SizedBox(height: 32),

            // Danger Zone
            _buildSectionHeader('Vùng nguy hiểm', isWarning: true),
            const SizedBox(height: 16),
            _buildActionTile(
              title: 'Xóa tài khoản',
              subtitle: 'Xóa vĩnh viễn tài khoản và dữ liệu',
              icon: Icons.delete_forever_outlined,
              onTap: _showDeleteAccountDialog,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isWarning = false}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isWarning 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: colorScheme.onSurface,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? colorScheme.error : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
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

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: colorScheme.onSurface,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
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

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
                );
                return;
              }

              try {
                final authModel = Provider.of<AuthModel>(context, listen: false);
                await authModel.updatePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi mật khẩu thành công')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  void _showAutoLockOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thời gian tự động khóa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _autoLockOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _autoLockTime,
              onChanged: (value) {
                setState(() {
                  _autoLockTime = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác và tất cả dữ liệu sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
  }
}