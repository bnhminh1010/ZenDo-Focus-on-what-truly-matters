import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_model.dart';
import '../../theme.dart';

/// Trang đăng nhập của ứng dụng ZenDo
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Xử lý đăng nhập
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authModel = context.read<AuthModel>();
    
    try {
      final success = await authModel.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        _showErrorSnackBar('Email hoặc mật khẩu không đúng');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Đã xảy ra lỗi: ${e.toString()}');
      }
    }
  }

  /// Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Validator cho email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    
    // Trim whitespace
    final email = value.trim();
    
    // Improved email regex that matches RFC 5322 standard
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    
    // Additional checks
    if (email.length > 254) {
      return 'Email quá dài';
    }
    
    return null;
  }

  /// Validator cho mật khẩu
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 40),
                
                // Login form
                _buildLoginForm(),
                
                const SizedBox(height: 24),
                
                // Sign in button
                _buildSignInButton(),
                
                const SizedBox(height: 16),
                
                // Forgot password
                _buildForgotPassword(),
                
                const SizedBox(height: 40),
                
                // Sign up link
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget header với tiêu đề
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đăng nhập',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 32,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Chào mừng bạn trở lại! Vui lòng nhập thông tin đăng nhập.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// Widget form đăng nhập
  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email field
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Nhập email của bạn',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.email_outlined, 
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Password field
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleSignIn(),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Nhập mật khẩu của bạn',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.lock_outlined, 
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Remember me checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
              checkColor: Colors.white,
            ),
            Text(
              'Ghi nhớ đăng nhập',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  /// Widget nút đăng nhập
  Widget _buildSignInButton() {
    return Consumer<AuthModel>(
      builder: (context, authModel, child) {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authModel.isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: authModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Đăng nhập',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Widget quên mật khẩu
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng quên mật khẩu sẽ được cập nhật sớm'),
            ),
          );
        },
        child: Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Widget link đến trang đăng ký
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/register'),
          child: Text(
            'Đăng ký',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}