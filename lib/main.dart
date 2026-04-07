import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/models/user_model.dart';
import 'modules/login/login_barrel.dart';
import 'modules/login/dialogs/auth_flow_dialogs.dart';
import 'modules/app_shell/app_shell_barrel.dart';
import 'screens/admin_login_screen.dart';
import 'screens/google_signup_credentials_screen.dart';

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
  AuthFlowState _authFlowState = AuthFlowState.splash;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    print('🎯 [AppRoot] initState - Checking for existing session');
    
    // Check if there's already an authenticated user from OAuth redirect
    final authUser = SupabaseService.client.auth.currentUser;
    
    if (authUser != null) {
      print('✅ [AppRoot] Found existing session: ${authUser.email}');
      
      // Initialize LoginProvider from the session
      if (mounted) {
        final loginProvider = context.read<LoginProvider>();
        await loginProvider.initializeFromExistingSession();
        
        if (loginProvider.isAuthenticated) {
          setState(() => _authFlowState = AuthFlowState.authenticated);
        } else if (loginProvider.googleSignUpData != null) {
          // User authenticated but no database record - show credentials form
          setState(() => _authFlowState = AuthFlowState.signupForm);
        } else {
          // Error or no state detected
          setState(() => _authFlowState = AuthFlowState.splash);
        }
      }
    } else {
      // No existing session, start from splash
      setState(() => _authFlowState = AuthFlowState.splash);
      print('🖼️  [AppRoot] No session found, showing splash');
    }
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
            onLogout: () async {
              await loginProvider.logout();
              if (mounted) {
                setState(() => _authFlowState = AuthFlowState.authChoice);
              }
            },
          );
        }

        // Show credentials screen if user just authenticated via OAuth
        if (loginProvider.googleSignUpData != null &&
            _authFlowState == AuthFlowState.signupForm) {
          print('📱 [AppRoot] Showing credentials screen for new OAuth user');
          return GoogleSignupCredentialsScreen(
            onBackPressed: () {
              loginProvider.clearError();
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
              onAdminLoginPressed: () {
                print('🎯 [AppRoot] Admin Login pressed, moving to adminLogin');
                setState(() => _authFlowState = AuthFlowState.adminLogin);
              },
            );

          case AuthFlowState.loginForm:
            return LoginFormScreen(
              onBackPressed: () {
                setState(() => _authFlowState = AuthFlowState.authChoice);
              },
              onLoginPressed: (email, password) async {
                print('📱 [AppRoot] Login pressed - calling loginWithEmail directly');
                // Login directly - role will be fetched from database
                await loginProvider.loginWithEmail(email, password, UserRole.student);
                
                if (context.mounted) {
                  if (loginProvider.isAuthenticated) {
                    print('✅ [AppRoot] Login successful - Consumer will handle navigation');
                    // The Consumer will catch the authenticated state and show AppShell
                  } else if (loginProvider.errorMessage != null) {
                    print('❌ [AppRoot] Login failed: ${loginProvider.errorMessage}');
                    
                    // Show error dialog with helpful message
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        icon: Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        title: const Text('Login Failed'),
                        content: Text(loginProvider.errorMessage!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              onGooglePressed: () async {
                print('🎯 [AppRoot] Google login pressed - calling loginWithGoogle directly');
                // Login directly with Google - role will be handled by Supabase OAuth
                await loginProvider.loginWithGoogle(UserRole.student);
                
                if (context.mounted) {
                  if (loginProvider.isAuthenticated) {
                    print('✅ [AppRoot] Google login successful - Consumer will handle navigation');
                    // The Consumer will catch the authenticated state and show AppShell
                  } else if (loginProvider.errorMessage != null) {
                    print('❌ [AppRoot] Google login failed: ${loginProvider.errorMessage}');
                    
                    // Show error dialog with helpful message
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        icon: Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        title: const Text('Google Login Failed'),
                        content: Text(loginProvider.errorMessage!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            );

          case AuthFlowState.signupForm:
            return SignUpFormScreen(
              onBackPressed: () {
                setState(() => _authFlowState = AuthFlowState.authChoice);
              },
            );

          case AuthFlowState.adminLogin:
            return AdminLoginScreen(
              onBackPressed: () {
                setState(() => _authFlowState = AuthFlowState.authChoice);
              },
              onLoginPressed: (username, password) async {
                print('📱 [AppRoot] Admin login pressed');
                await loginProvider.adminLogin(username, password);
                
                if (context.mounted) {
                  if (loginProvider.isAuthenticated) {
                    print('✅ [AppRoot] Admin login successful - no state change needed');
                    // The Consumer will catch the authenticated state and show AppShell
                  } else if (loginProvider.errorMessage != null) {
                    print('❌ [AppRoot] Admin login failed: ${loginProvider.errorMessage}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login Failed: ${loginProvider.errorMessage}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
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
