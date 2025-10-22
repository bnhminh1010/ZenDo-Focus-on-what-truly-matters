import 'package:flutter/material.dart';

/// Enum cho mức độ mạnh của mật khẩu
enum PasswordStrength { weak, fair, good, strong }

/// Widget hiển thị độ mạnh của mật khẩu
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showText;
  final EdgeInsets? padding;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showText = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bars
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: index < _getStrengthLevel(strength)
                        ? _getStrengthColor(strength)
                        : theme.colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),

          if (showText && password.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getStrengthIcon(strength),
                  size: 16,
                  color: _getStrengthColor(strength),
                ),
                const SizedBox(width: 4),
                Text(
                  _getStrengthText(strength),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStrengthColor(strength),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildRequirements(context),
          ],
        ],
      ),
    );
  }

  /// Tính toán độ mạnh của mật khẩu
  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Độ dài
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Chữ thường
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Chữ hoa
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Số
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Ký tự đặc biệt
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Không có ký tự lặp liên tiếp
    if (!password.contains(RegExp(r'(.)\1{2,}'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  /// Lấy số level của strength (1-4)
  int _getStrengthLevel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.good:
        return 3;
      case PasswordStrength.strong:
        return 4;
    }
  }

  /// Lấy màu sắc theo độ mạnh
  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.blue;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  /// Lấy icon theo độ mạnh
  IconData _getStrengthIcon(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Icons.error_outline;
      case PasswordStrength.fair:
        return Icons.warning_amber_outlined;
      case PasswordStrength.good:
        return Icons.check_circle_outline;
      case PasswordStrength.strong:
        return Icons.verified_outlined;
    }
  }

  /// Lấy text mô tả độ mạnh
  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Yếu';
      case PasswordStrength.fair:
        return 'Trung bình';
      case PasswordStrength.good:
        return 'Tốt';
      case PasswordStrength.strong:
        return 'Mạnh';
    }
  }

  /// Hiển thị các yêu cầu mật khẩu
  Widget _buildRequirements(BuildContext context) {
    final theme = Theme.of(context);

    final requirements = [
      _PasswordRequirement(
        text: 'Ít nhất 8 ký tự',
        isMet: password.length >= 8,
      ),
      _PasswordRequirement(
        text: 'Chứa chữ thường',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      _PasswordRequirement(
        text: 'Chứa chữ hoa',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      _PasswordRequirement(
        text: 'Chứa số',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      _PasswordRequirement(
        text: 'Chứa ký tự đặc biệt',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((req) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(
                req.isMet ? Icons.check : Icons.close,
                size: 12,
                color: req.isMet ? Colors.green : theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                req.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: req.isMet ? Colors.green : theme.colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Class helper cho yêu cầu mật khẩu
class _PasswordRequirement {
  final String text;
  final bool isMet;

  _PasswordRequirement({required this.text, required this.isMet});
}

/// Widget text field với password strength indicator
class PasswordFieldWithStrength extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool showStrengthIndicator;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onChanged;

  const PasswordFieldWithStrength({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.showStrengthIndicator = true,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordFieldWithStrength> createState() =>
      _PasswordFieldWithStrengthState();
}

class _PasswordFieldWithStrengthState extends State<PasswordFieldWithStrength> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: (_) {
            setState(() {});
            widget.onChanged?.call();
          },
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),

        if (widget.showStrengthIndicator)
          PasswordStrengthIndicator(
            password: widget.controller.text,
            padding: const EdgeInsets.only(top: 8),
          ),
      ],
    );
  }
}

