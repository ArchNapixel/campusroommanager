import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'modules/login/login_barrel.dart';
import 'modules/login/dialogs/auth_flow_dialogs.dart';
import 'modules/app_shell/app_shell_barrel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
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

/// Root widget that handles navigation through the authentication flow
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late AuthFlowState _authFlowState;

  @override
  void initState() {
    super.initState();
    _authFlowState = AuthFlowState.splash;
    print('🎯 [AppRoot] initState - Setting state to splash');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        print('🔄 [AppRoot] Consumer rebuild - authFlowState: $_authFlowState, isAuthenticated: ${loginProvider.isAuthenticated}');
        // Navigate to authenticated state if user is already logged in
        if (loginProvider.isAuthenticated &&
            loginProvider.currentUserRole != null &&
            _authFlowState != AuthFlowState.authenticated) {
          _authFlowState = AuthFlowState.authenticated;
          print('🎯 [AppRoot] Authenticated detected, moving to authenticated');
        }

        // Show authenticated app
        if (loginProvider.isAuthenticated &&
            loginProvider.currentUserRole != null) {
          return AppShell(
            userRole: loginProvider.currentUserRole!,
            onLogout: () {
              loginProvider.logout();
              setState(() => _authFlowState = AuthFlowState.authChoice);
            },
          );
        }

        // Show different screens based on auth flow state
        switch (_authFlowState) {
          case AuthFlowState.splash:
            print('🖼️  [AppRoot] Showing SplashScreen');
            return SplashScreen(
              onSplashComplete: () {
                print('🎯 [AppRoot] SplashScreen complete, moving to authChoice');
                setState(() => _authFlowState = AuthFlowState.authChoice);
              },
            );

          case AuthFlowState.authChoice:
            print('🖼️  [AppRoot] Showing AuthChoiceScreen');
            return AuthChoiceScreen(
              onLoginPressed: () {
                print('🎯 [AppRoot] Login pressed, moving to loginForm');
                setState(() => _authFlowState = AuthFlowState.loginForm);
              },
              onSignUpPressed: () {
                print('🎯 [AppRoot] SignUp pressed, moving to signupForm');
                setState(() => _authFlowState = AuthFlowState.signupForm);
              },
            );

          case AuthFlowState.loginForm:
            return LoginFormScreen(
              onBackPressed: () {
                setState(() => _authFlowState = AuthFlowState.authChoice);
              },
              onLoginPressed: (email, password) {
                // Don't change state to roleSelection - keep showing loginForm
                // Dialog will appear on top, and on error we'll already be on this form
                AuthFlowDialogs.showLoginRoleSelection(
                  context,
                  loginProvider,
                  email,
                  password,
                  setState,
                  () => setState(() => _authFlowState = AuthFlowState.loginForm),
                );
              },
              onGooglePressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google login coming soon!')),
                );
              },
            );

          case AuthFlowState.signupForm:
            return SignUpFormScreen(
              onBackPressed: () {
                setState(() => _authFlowState = AuthFlowState.authChoice);
              },
              onSignUpPressed: (username, email, password) {
                // Don't change state to roleSelection - keep showing signupForm
                // Dialog will appear on top, and on error we'll already be on this form
                AuthFlowDialogs.showSignupRoleSelection(
                  context,
                  loginProvider,
                  username,
                  email,
                  password,
                  setState,
                  () => setState(() => _authFlowState = AuthFlowState.signupForm),
                );
              },
            );

          case AuthFlowState.roleSelection:
            // Not used - dialogs appear on top of form screens
            return Center(child: CircularProgressIndicator());

          case AuthFlowState.authenticated:
            return SizedBox();
        }
      },
    );
  }
}
