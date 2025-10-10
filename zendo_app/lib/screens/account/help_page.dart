import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../config/app_info.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
          'Trợ giúp & Hỗ trợ',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Section
            _buildSectionHeader(context, 'Trợ giúp nhanh'),
            const SizedBox(height: 16),
            _buildHelpTile(
              context,
              title: 'Hướng dẫn sử dụng',
              subtitle: 'Tìm hiểu cách sử dụng ZenDo',
              icon: Icons.help_outline,
              onTap: () => _showUserGuide(context),
            ),
            _buildHelpTile(
              context,
              title: 'Câu hỏi thường gặp',
              subtitle: 'Giải đáp các thắc mắc phổ biến',
              icon: Icons.quiz_outlined,
              onTap: () => _showFAQ(context),
            ),
            _buildHelpTile(
              context,
              title: 'Mẹo & Thủ thuật',
              subtitle: 'Sử dụng ZenDo hiệu quả hơn',
              icon: Icons.lightbulb_outline,
              onTap: () => _showTipsAndTricks(context),
            ),

            const SizedBox(height: 32),

            // Contact Section
            _buildSectionHeader(context, 'Liên hệ hỗ trợ'),
            const SizedBox(height: 16),
            _buildHelpTile(
              context,
              title: 'Gửi phản hồi',
              subtitle: 'Chia sẻ ý kiến của bạn',
              icon: Icons.feedback_outlined,
              onTap: () => _showFeedbackForm(context),
            ),
            _buildHelpTile(
              context,
              title: 'Báo lỗi',
              subtitle: 'Báo cáo sự cố hoặc lỗi',
              icon: Icons.bug_report_outlined,
              onTap: () => _showBugReport(context),
            ),
            _buildHelpTile(
              context,
              title: 'Email hỗ trợ',
              subtitle: AppInfo.supportEmail,
              icon: Icons.email_outlined,
              onTap: () => _launchEmail(),
            ),

            const SizedBox(height: 32),

            // Community Section
            _buildSectionHeader(context, 'Cộng đồng'),
            const SizedBox(height: 16),
            _buildHelpTile(
              context,
              title: 'GitHub Repository',
              subtitle: 'Mã nguồn và đóng góp',
              icon: Icons.code_outlined,
              onTap: () => _launchGitHub(),
            ),
            _buildHelpTile(
              context,
              title: 'Diễn đàn cộng đồng',
              subtitle: 'Thảo luận với người dùng khác',
              icon: Icons.forum_outlined,
              onTap: () => _launchCommunity(),
            ),

            const SizedBox(height: 32),

            // App Info Section
            _buildSectionHeader(context, 'Thông tin ứng dụng'),
            const SizedBox(height: 16),
            _buildInfoCard(context),

            const SizedBox(height: 32),

            // Emergency Contact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emergency_outlined,
                    color: colorScheme.onErrorContainer,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hỗ trợ khẩn cấp',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nếu bạn gặp sự cố nghiêm trọng, vui lòng liên hệ ngay',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _launchEmergencyContact(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: const Text('Liên hệ ngay'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildHelpTile(
    BuildContext context, {
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

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.apps,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppInfo.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppInfo.tagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '-';
              final build = snapshot.data?.buildNumber ?? '-';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, 'Phiên bản', version),
                  _buildInfoRow(context, 'Bản dựng', build),
                  _buildInfoRow(context, 'Ngày phát hành', AppInfo.releaseDate),
                  _buildInfoRow(context, 'Nhà phát triển', AppInfo.developer),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hướng dẫn sử dụng'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Tạo công việc mới bằng nút "+" ở trang chủ'),
              SizedBox(height: 8),
              Text('2. Phân loại công việc theo danh mục'),
              SizedBox(height: 8),
              Text('3. Đặt mức độ ưu tiên cho từng công việc'),
              SizedBox(height: 8),
              Text('4. Theo dõi tiến độ trong trang thống kê'),
              SizedBox(height: 8),
              Text('5. Tùy chỉnh cài đặt trong trang tài khoản'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Câu hỏi thường gặp'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Q: Làm sao để xóa công việc?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('A: Vuốt sang trái trên công việc và chọn xóa.'),
              SizedBox(height: 16),
              Text(
                'Q: Có thể đồng bộ dữ liệu không?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('A: Có, dữ liệu được đồng bộ tự động khi đăng nhập.'),
              SizedBox(height: 16),
              Text(
                'Q: Làm sao để thay đổi chủ đề?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('A: Vào Cài đặt > Giao diện để thay đổi chủ đề.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTipsAndTricks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mẹo & Thủ thuật'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💡 Sử dụng mức độ ưu tiên để tập trung vào việc quan trọng'),
              SizedBox(height: 12),
              Text('⏰ Đặt thời hạn để tạo động lực hoàn thành'),
              SizedBox(height: 12),
              Text('📊 Xem thống kê để theo dõi hiệu suất'),
              SizedBox(height: 12),
              Text('🔔 Bật thông báo để không bỏ lỡ công việc'),
              SizedBox(height: 12),
              Text('📱 Sử dụng widget để truy cập nhanh'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackForm(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi phản hồi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chia sẻ ý kiến của bạn để giúp chúng tôi cải thiện ZenDo:'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nhập phản hồi của bạn...',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cảm ơn phản hồi của bạn!')),
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showBugReport(BuildContext context) {
    final bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo lỗi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mô tả chi tiết lỗi bạn gặp phải:'),
            const SizedBox(height: 16),
            TextField(
              controller: bugController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Mô tả lỗi và các bước tái hiện...',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã gửi báo cáo lỗi!')),
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppInfo.supportEmail,
      query: 'subject=ZenDo Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchGitHub() async {
    final Uri githubUri = Uri.parse(AppInfo.githubUrl);

    if (await canLaunchUrl(githubUri)) {
      await launchUrl(githubUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchCommunity() async {
    final Uri communityUri = Uri.parse(AppInfo.communityUrl);

    if (await canLaunchUrl(communityUri)) {
      await launchUrl(communityUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to GitHub discussions
      _launchGitHub();
    }
  }

  Future<void> _launchEmergencyContact() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppInfo.emergencyEmail,
      query: 'subject=ZenDo Emergency Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}