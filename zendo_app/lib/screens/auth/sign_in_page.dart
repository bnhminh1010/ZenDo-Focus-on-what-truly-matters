import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_model.dart';
import '../../providers/google_signin_provider.dart';
import '../../providers/github_signin_provider.dart';
import '../../widgets/google_signin_button.dart';
import '../../widgets/github_signin_button.dart';
import '../../theme.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/enhanced_loading_widget.dart';
import '../../widgets/theme_aware_logo.dart';

/// SignInPage Class
/// Tác dụng: Màn hình đăng nhập với form email/password và social login
/// Sử dụng khi: Người dùng chưa đăng nhập và cần xác thực để truy cập ứng dụng
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

/// _SignInPageState Class
/// Tác dụng: State class quản lý form validation, authentication logic và UI state
/// Sử dụng khi: Cần xử lý input validation, authentication flow và loading states
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

  /// _handleSignIn Method
  /// Tác dụng: Xử lý logic đăng nhập với email và password
  /// Sử dụng khi: Người dùng submit form đăng nhập
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
        // Hiển thị thông báo lỗi cụ thể khi đăng nhập thất bại
        _showErrorSnackBar(
          'Thông tin đăng nhập không chính xác. Vui lòng kiểm tra lại email và mật khẩu.',
        );
      }
    } catch (e) {
      if (mounted) {
        // Hiển thị thông báo lỗi chi tiết hơn
        String errorMessage = 'Đã xảy ra lỗi khi đăng nhập';

        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Email hoặc mật khẩu không đúng. Vui lòng thử lại.';
        } else if (e.toString().contains('Email not confirmed')) {
          errorMessage =
              'Email chưa được xác thực. Vui lòng kiểm tra hộp thư của bạn.';
        } else if (e.toString().contains('Too many requests')) {
          errorMessage =
              'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau ít phút.';
        } else if (e.toString().contains('Network')) {
          errorMessage =
              'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        }

        _showErrorSnackBar(errorMessage);
      }
    }
  }

  /// Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
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
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
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

                const SizedBox(height: 24),

                // Divider with "hoặc"
                _buildDivider(),

                const SizedBox(height: 24),

                // Google Sign-In button
                _buildGoogleSignInButton(),

                const SizedBox(height: 16),

                // GitHub Sign-In button
                _buildGitHubSignInButton(),

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
        // Logo
        Center(
          child: AnimatedThemeAwareLogo(
            width: 80,
            height: 80,
          ),
        ),
        
        const SizedBox(height: 24),
        
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.7),
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
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.3),
            ),
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Nhập email của bạn',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.5),
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
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.3),
            ),
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Nhập mật khẩu của bạn',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.5),
              ),
              suffixIcon: GlassIconButton(
                icon: _isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                iconColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.5),
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
              checkColor: Theme.of(context).colorScheme.onPrimary,
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
          child: LoadingButton(
            onPressed: _handleSignIn,
            isLoading: authModel.isLoading,
            loadingText: 'Đang đăng nhập...',
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
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
      child: GlassTextButton(
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        GlassTextButton(
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

  /// Widget divider với text "hoặc"
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'hoặc',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Widget Google Sign-In button
  Widget _buildGoogleSignInButton() {
    return GoogleSignInButton(
      onSignInSuccess: () {
        // Chuyển đến trang home sau khi đăng nhập thành công
        context.go('/home');
      },
    );
  }

  /// Widget GitHub Sign-In button
  Widget _buildGitHubSignInButton() {
    return GitHubSignInButton(
      onPressed: () async {
        final provider = context.read<GitHubSignInProvider>();
        final success = await provider.signIn();

        if (success && mounted) {
          // Chuyển đến trang home sau khi đăng nhập thành công
          context.go('/home');
        }
      },
    );
  }
}

