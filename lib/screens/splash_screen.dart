import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Splash screen displayed on app launch
class SplashScreen extends StatefulWidget {
  final Function onSplashComplete;

  const SplashScreen({
    Key? key,
    required this.onSplashComplete,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Navigate after splash duration
    Future.delayed(Duration(seconds: 3), () {
      print('✨ [SplashScreen] 3 seconds passed, calling onSplashComplete()');
      widget.onSplashComplete();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepNavy,
              AppColors.primaryBackground,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Icon(
                        Icons.meeting_room,
                        size: 80,
                        color: AppColors.available,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Campus Room Manager',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              color: AppColors.headerText,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Book labs and AV rooms instantly',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedText,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.available,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
