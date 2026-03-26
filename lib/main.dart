import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'modules/login/login_barrel.dart';
import 'modules/app_shell/app_shell_barrel.dart';

void main() {
  runApp(const CampusRoomManagerApp());
}

class CampusRoomManagerApp extends StatelessWidget {
  const CampusRoomManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: MaterialApp(
        title: 'Campus Room Manager',
        theme: AppTheme.darkTheme,
        home: const AppRoot(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Root widget that handles navigation between login and main app
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        if (!loginProvider.isAuthenticated || loginProvider.currentUserRole == null) {
          return LoginScreen(
            onRoleSelected: (role) {
              loginProvider.login(
                role,
                'user@university.edu',
                'password',
              );
            },
          );
        }

        return AppShell(
          userRole: loginProvider.currentUserRole!,
          onLogout: () => loginProvider.logout(),
        );
      },
    );
  }
}
