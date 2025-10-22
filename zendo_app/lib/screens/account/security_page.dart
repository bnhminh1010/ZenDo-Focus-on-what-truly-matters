import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_model.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import 'package:go_router/go_router.dart';

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
  int _autoLockMinutes = 5; // Thêm biến này

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Bảo mật', style: theme.textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        // Tăng bottom padding để tránh chồng lấn với navigation bar
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
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

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 12,
      blur: 16,
      opacity: 0.14,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: colorScheme.onSurface, size: 24),
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

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 12,
      blur: 16,
      opacity: 0.14,
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

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 12,
      blur: 16,
      opacity: 0.14,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: colorScheme.onSurface, size: 24),
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

  /// Validator cho mật khẩu mới với quy tắc bảo mật mạnh
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }

    // Kiểm tra độ dài tối thiểu
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    // Kiểm tra độ dài tối đa
    if (value.length > 128) {
      return 'Mật khẩu không được quá 128 ký tự';
    }

    // Kiểm tra có chữ thường
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường (a-z)';
    }

    // Kiểm tra có chữ hoa
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa (A-Z)';
    }

    // Kiểm tra có số
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số (0-9)';
    }

    // Kiểm tra có ký tự đặc biệt
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt (!@#\$%^&*...)';
    }

    // Kiểm tra không có khoảng trắng
    if (value.contains(' ')) {
      return 'Mật khẩu không được chứa khoảng trắng';
    }

    // Kiểm tra không có ký tự lặp liên tiếp quá 2 lần
    if (RegExp(r'(.)\1{2,}').hasMatch(value)) {
      return 'Mật khẩu không được có ký tự lặp liên tiếp quá 2 lần';
    }

    return null;
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đổi mật khẩu',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Cập nhật mật khẩu bảo mật',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Current Password
                    Semantics(
                      label: 'Mật khẩu hiện tại',
                      hint: 'Nhập mật khẩu hiện tại của bạn',
                      child: TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainer,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu hiện tại';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // New Password
                    Semantics(
                      label: 'Mật khẩu mới',
                      hint: 'Nhập mật khẩu mới, ít nhất 8 ký tự',
                      child: TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainer,
                          helperText:
                              'Ít nhất 8 ký tự, có chữ hoa, chữ thường, số và ký tự đặc biệt',
                          helperMaxLines: 3,
                        ),
                        validator: _validateNewPassword,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    Semantics(
                      label: 'Xác nhận mật khẩu mới',
                      hint: 'Nhập lại mật khẩu mới để xác nhận',
                      child: TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainer,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu mới';
                          }
                          if (value != newPasswordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Hủy thay đổi mật khẩu',
                      hint: 'Nhấn để đóng dialog mà không lưu',
                      child: GlassOutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      label: 'Lưu mật khẩu mới',
                      hint: 'Nhấn để cập nhật mật khẩu',
                      child: GlassElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            final authModel = Provider.of<AuthModel>(
                              context,
                              listen: false,
                            );
                            await authModel.updatePassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );

                            if (mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đổi mật khẩu thành công'),
                                ),
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAutoLockOptions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tự động khóa',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Chọn thời gian tự động khóa ứng dụng',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Options
              Column(
                children: [
                  Semantics(
                    label: 'Không tự động khóa',
                    hint: 'Ứng dụng sẽ không tự động khóa',
                    child: RadioListTile<int>(
                      title: const Text('Không bao giờ'),
                      subtitle: const Text('Ứng dụng sẽ không tự động khóa'),
                      value: 0,
                      groupValue: _autoLockMinutes,
                      onChanged: (value) {
                        setState(() {
                          _autoLockMinutes = value!;
                        });
                        _saveAutoLockSetting(value.toString());
                        context.pop();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Tự động khóa sau 1 phút',
                    hint: 'Ứng dụng sẽ tự động khóa sau 1 phút không hoạt động',
                    child: RadioListTile<int>(
                      title: const Text('1 phút'),
                      subtitle: const Text('Khóa nhanh để bảo mật cao'),
                      value: 1,
                      groupValue: _autoLockMinutes,
                      onChanged: (value) {
                        setState(() {
                          _autoLockMinutes = value!;
                        });
                        _saveAutoLockSetting(value.toString());
                        context.pop();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Tự động khóa sau 5 phút',
                    hint: 'Ứng dụng sẽ tự động khóa sau 5 phút không hoạt động',
                    child: RadioListTile<int>(
                      title: const Text('5 phút'),
                      subtitle: const Text('Cân bằng giữa tiện lợi và bảo mật'),
                      value: 5,
                      groupValue: _autoLockMinutes,
                      onChanged: (value) {
                        setState(() {
                          _autoLockMinutes = value!;
                        });
                        _saveAutoLockSetting(value.toString());
                        context.pop();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Tự động khóa sau 15 phút',
                    hint:
                        'Ứng dụng sẽ tự động khóa sau 15 phút không hoạt động',
                    child: RadioListTile<int>(
                      title: const Text('15 phút'),
                      subtitle: const Text(
                        'Thời gian dài hơn cho công việc liên tục',
                      ),
                      value: 15,
                      groupValue: _autoLockMinutes,
                      onChanged: (value) {
                        setState(() {
                          _autoLockMinutes = value!;
                        });
                        _saveAutoLockSetting(value.toString());
                        context.pop();
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: 'Đóng dialog tự động khóa',
                  hint: 'Nhấn để đóng dialog',
                  child: GlassTextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Đóng'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.warning_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xóa tài khoản',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                        Text(
                          'Hành động này không thể hoàn tác',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Warning content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dữ liệu sẽ bị xóa vĩnh viễn:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...const [
                      '• Tất cả nhiệm vụ và dự án',
                      '• Lịch sử hoạt động và thống kê',
                      '• Cài đặt cá nhân',
                      '• Dữ liệu đồng bộ trên các thiết bị',
                    ].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Hủy xóa tài khoản',
                      hint: 'Nhấn để hủy và giữ lại tài khoản',
                      child: GlassOutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      label: 'Xác nhận xóa tài khoản',
                      hint: 'Nhấn để xóa vĩnh viễn tài khoản và tất cả dữ liệu',
                      child: GlassElevatedButton(
                        onPressed: () {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng đang phát triển'),
                            ),
                          );
                        },
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        child: const Text('Xóa tài khoản'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method để lưu cài đặt auto lock
  void _saveAutoLockSetting(String value) {
    // TODO: Implement save auto lock setting
    debugPrint('Auto lock setting saved: $value');
  }
}

