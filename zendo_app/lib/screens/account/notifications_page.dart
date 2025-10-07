import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _taskReminders = true;
  bool _dailyDigest = false;
  bool _weeklyReport = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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
          'Cài đặt thông báo',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Notifications Section
            _buildSectionHeader('Thông báo chung'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Thông báo đẩy',
              subtitle: 'Nhận thông báo trên thiết bị',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
              icon: Icons.notifications_outlined,
            ),
            _buildSwitchTile(
              title: 'Thông báo email',
              subtitle: 'Nhận thông báo qua email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 32),

            // Task Notifications Section
            _buildSectionHeader('Thông báo công việc'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Nhắc nhở công việc',
              subtitle: 'Thông báo khi đến hạn công việc',
              value: _taskReminders,
              onChanged: (value) {
                setState(() {
                  _taskReminders = value;
                });
              },
              icon: Icons.task_outlined,
            ),
            _buildSwitchTile(
              title: 'Tóm tắt hàng ngày',
              subtitle: 'Báo cáo tiến độ công việc mỗi ngày',
              value: _dailyDigest,
              onChanged: (value) {
                setState(() {
                  _dailyDigest = value;
                });
              },
              icon: Icons.today_outlined,
            ),
            _buildSwitchTile(
              title: 'Báo cáo tuần',
              subtitle: 'Thống kê hiệu suất làm việc hàng tuần',
              value: _weeklyReport,
              onChanged: (value) {
                setState(() {
                  _weeklyReport = value;
                });
              },
              icon: Icons.bar_chart_outlined,
            ),

            const SizedBox(height: 32),

            // Sound & Vibration Section
            _buildSectionHeader('Âm thanh & rung'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Âm thanh',
              subtitle: 'Phát âm thanh khi có thông báo',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              icon: Icons.volume_up_outlined,
            ),
            _buildSwitchTile(
              title: 'Rung',
              subtitle: 'Rung thiết bị khi có thông báo',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              icon: Icons.vibration_outlined,
            ),

            const SizedBox(height: 32),

            // Notification Time Section
            _buildSectionHeader('Thời gian thông báo'),
            const SizedBox(height: 16),
            _buildTimeTile(
              title: 'Không làm phiền',
              subtitle: '22:00 - 07:00',
              onTap: () {
                _showTimeRangePicker();
              },
            ),

            const SizedBox(height: 40),

            // Reset Button
            Center(
              child: OutlinedButton(
                onPressed: _resetToDefault,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Khôi phục mặc định',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
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

  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.bedtime_outlined,
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
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showTimeRangePicker() {
    // TODO: Implement time range picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển'),
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _pushNotifications = true;
      _emailNotifications = false;
      _taskReminders = true;
      _dailyDigest = false;
      _weeklyReport = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã khôi phục cài đặt mặc định'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}