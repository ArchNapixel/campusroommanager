import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Dialog for admin security code verification
class AdminSecurityCodeDialog extends StatefulWidget {
  final Function(bool isValid) onCodeSubmitted;

  const AdminSecurityCodeDialog({
    Key? key,
    required this.onCodeSubmitted,
  }) : super(key: key);

  @override
  State<AdminSecurityCodeDialog> createState() =>
      _AdminSecurityCodeDialogState();
}

class _AdminSecurityCodeDialogState extends State<AdminSecurityCodeDialog> {
  final securityCodeController = TextEditingController();
  bool isCodeObscured = true;
  static const String ADMIN_CODE = '0000';

  @override
  void dispose() {
    securityCodeController.dispose();
    super.dispose();
  }

  void _verifyCode() {
    final isValid = securityCodeController.text == ADMIN_CODE;
    if (isValid) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid security code'),
          backgroundColor: AppColors.error,
        ),
      );
      securityCodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security,
                size: 48,
                color: AppColors.warning,
              ),
              SizedBox(height: 16),
              Text(
                'Admin Access Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.headerText,
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Enter the security code to register as Administrator',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextField(
                controller: securityCodeController,
                decoration: InputDecoration(
                  labelText: 'Security Code',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isCodeObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => isCodeObscured = !isCodeObscured);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: isCodeObscured,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderColor),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Verify'),
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
}
