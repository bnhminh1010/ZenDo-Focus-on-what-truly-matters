import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authModel = Provider.of<AuthModel>(context, listen: false);
    _nameController.text = authModel.userName ?? '';
    _emailController.text = authModel.userEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
          'Thông tin cá nhân',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: Icon(
                Icons.edit_outlined,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
      body: Consumer<AuthModel>(
        builder: (context, authModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // TODO: Implement image picker
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tính năng đang phát triển'),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Field
                  Text(
                    'Họ và tên',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isEditing ? colorScheme.surface : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Nhập họ và tên',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email Field
                  Text(
                    'Email',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isEditing ? colorScheme.surface : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Nhập email',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                // Reset values
                                _nameController.text = authModel.userName ?? '';
                                _emailController.text = authModel.userEmail ?? '';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: authModel.isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authModel.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Lưu',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final success = await authModel.updateProfile(
      _nameController.text.trim(),
      _emailController.text.trim(),
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cập nhật thông tin thành công'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cập nhật thông tin thất bại'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}