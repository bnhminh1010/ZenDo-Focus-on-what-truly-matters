import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_model.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/loading_state_widget.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isEditing = false;
  File? _selectedImage;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final authModel = Provider.of<AuthModel>(context, listen: false);
    _nameController.text = authModel.userName ?? '';
    _emailController.text = authModel.userEmail ?? '';
    // TODO: Load phone, bio, avatar from user profile when available
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Hiển thị dialog chọn nguồn ảnh
  void _showImageSourceDialog() {
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
                      Icons.photo_camera_outlined,
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
                          'Chọn ảnh đại diện',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Chọn nguồn ảnh để cập nhật',
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
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Chụp ảnh từ camera',
                      hint: 'Nhấn để mở camera và chụp ảnh mới',
                      child: GlassElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          _pickImage(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      label: 'Chọn ảnh từ thư viện',
                      hint: 'Nhấn để mở thư viện ảnh và chọn ảnh có sẵn',
                      child: GlassElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          _pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Thư viện'),
                      ),
                    ),
                  ),
                ],
              ),

              if (_selectedImage != null || _currentAvatarUrl != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: 'Xóa ảnh đại diện',
                    hint: 'Nhấn để xóa ảnh đại diện hiện tại',
                    child: GlassOutlinedButton(
                      onPressed: () {
                        context.pop();
                        _removeAvatar();
                      },
                      borderColor: Theme.of(context).colorScheme.error,
                      textColor: Theme.of(context).colorScheme.error,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text('Xóa ảnh'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: 'Hủy chọn ảnh',
                  hint: 'Nhấn để đóng dialog và hủy thao tác',
                  child: GlassTextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Hủy'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget option cho việc chọn nguồn ảnh
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chọn ảnh từ camera hoặc gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Xóa avatar
  void _removeAvatar() {
    setState(() {
      _selectedImage = null;
      _currentAvatarUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Thông tin cá nhân', style: theme.textTheme.titleLarge),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
            ),
        ],
      ),
      body: Consumer<AuthModel>(
        builder: (context, authModel, child) {
          return SingleChildScrollView(
            // Tăng bottom padding để tránh chồng lấn với navigation bar
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section với Glass Effect
                  Center(
                    child: GlassContainer(
                      borderRadius: 80,
                      blur: 16,
                      opacity: 0.14,
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : _currentAvatarUrl != null
                                  ? NetworkImage(_currentAvatarUrl!)
                                  : null,
                              child:
                                  (_selectedImage == null &&
                                      _currentAvatarUrl == null)
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: colorScheme.onSurfaceVariant,
                                    )
                                  : null,
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
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: _showImageSourceDialog,
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
                  ),

                  const SizedBox(height: 40),

                  // Name Field
                  _buildInputField(
                    label: 'Họ và tên',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hintText: 'Nhập họ và tên',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Email Field
                  _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hintText: 'Nhập email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Phone Field
                  _buildInputField(
                    label: 'Số điện thoại',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hintText: 'Nhập số điện thoại',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Bio Field
                  _buildInputField(
                    label: 'Giới thiệu bản thân',
                    controller: _bioController,
                    icon: Icons.info_outline,
                    hintText: 'Viết vài dòng về bản thân...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: GlassOutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                // Reset values
                                _nameController.text = authModel.userName ?? '';
                                _emailController.text =
                                    authModel.userEmail ?? '';
                                _phoneController.clear();
                                _bioController.clear();
                                _selectedImage = null;
                              });
                            },
                            child: Text(
                              'Hủy',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassElevatedButton(
                            onPressed: authModel.isLoading
                                ? null
                                : _saveProfile,
                            child: authModel.isLoading
                                ? const LoadingStateWidget(size: 20)
                                : Text(
                                    'Lưu',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
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

  /// Widget tái sử dụng cho các input field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          borderRadius: 12,
          blur: 16,
          opacity: 0.14,
          child: TextFormField(
            controller: controller,
            enabled: _isEditing,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                icon,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  /// Lưu thông tin profile
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authModel = Provider.of<AuthModel>(context, listen: false);

    // TODO: Implement avatar upload to Supabase Storage
    // For now, just update name and email
    final success = await authModel.updateProfile(
      _nameController.text.trim(),
      _emailController.text.trim(),
    );

    if (success) {
      setState(() {
        _isEditing = false;
        // TODO: Save avatar URL after upload
        if (_selectedImage != null) {
          // Convert selected image to avatar URL after upload
          // _currentAvatarUrl = uploadedUrl;
          _selectedImage = null;
        }
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

