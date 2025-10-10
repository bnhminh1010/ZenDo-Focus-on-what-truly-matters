import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'vi';

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'vi',
      'name': 'Tiếng Việt',
      'nativeName': 'Tiếng Việt',
      'flag': '🇻🇳',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'ja',
      'name': 'Japanese',
      'nativeName': '日本語',
      'flag': '🇯🇵',
    },
    {
      'code': 'ko',
      'name': 'Korean',
      'nativeName': '한국어',
      'flag': '🇰🇷',
    },
    {
      'code': 'zh',
      'name': 'Chinese',
      'nativeName': '中文',
      'flag': '🇨🇳',
    },
    {
      'code': 'fr',
      'name': 'French',
      'nativeName': 'Français',
      'flag': '🇫🇷',
    },
    {
      'code': 'de',
      'name': 'German',
      'nativeName': 'Deutsch',
      'flag': '🇩🇪',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
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
          'Ngôn ngữ',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: _saveLanguageSettings,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Language Info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _getCurrentLanguage()['flag'],
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ngôn ngữ hiện tại',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentLanguage()['nativeName'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Language List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = language['code'] == _selectedLanguage;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          language['flag'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      language['name'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                    ),
                    subtitle: Text(
                      language['nativeName'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? colorScheme.primary.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 24,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language['code'];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ứng dụng sẽ khởi động lại để áp dụng ngôn ngữ mới',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCurrentLanguage() {
    return _languages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => _languages[0],
    );
  }

  void _saveLanguageSettings() {
    // TODO: Implement language saving logic
    // This would typically involve:
    // 1. Saving to SharedPreferences
    // 2. Updating app locale
    // 3. Restarting the app or updating the locale provider

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay đổi ngôn ngữ'),
        content: Text(
          'Bạn có muốn thay đổi ngôn ngữ thành ${_getCurrentLanguage()['nativeName']}? Ứng dụng sẽ khởi động lại để áp dụng thay đổi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyLanguageChange();
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  void _applyLanguageChange() {
    // TODO: Implement actual language change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu ngôn ngữ: ${_getCurrentLanguage()['nativeName']}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'Khởi động lại',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            // TODO: Restart app or update locale
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng đang phát triển'),
              ),
            );
          },
        ),
      ),
    );

    // Navigate back after saving
    Navigator.pop(context);
  }
}