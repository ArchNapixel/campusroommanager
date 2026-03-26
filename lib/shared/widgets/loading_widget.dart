import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Loading widget for async operations
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.buttonPrimary),
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
