import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(authProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          password: _newPasswordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нууц үг амжилттай солигдлоо.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final authState = ref.read(authProvider);
        setState(() => _error = authState.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Нууц үг солих'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Одоогийн нууц үг',
                hintText: '••••••••',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                validator: (v) =>
                    Validator.required(v, 'Одоогийн нууц үгээ оруулна уу.'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _newPasswordController,
                label: 'Шинэ нууц үг',
                hintText: 'Хамгийн багадаа 6 тэмдэгт',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_reset, size: 20),
                validator: Validator.password,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Шинэ нууц үг давтах',
                hintText: 'Дахин оруулна уу',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_reset, size: 20),
                validator: (v) =>
                    Validator.confirmPassword(v, _newPasswordController.text),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Болих'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Солих'),
        ),
      ],
    );
  }
}
