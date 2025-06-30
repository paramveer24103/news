import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  final bool isFirstTime;
  
  const AuthWrapper({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while initializing
        if (authProvider.state == AuthState.initial || 
            authProvider.state == AuthState.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show onboarding for first-time users
        if (widget.isFirstTime) {
          return const OnboardingScreen();
        }

        // Show login screen if not authenticated
        if (authProvider.state == AuthState.unauthenticated || 
            authProvider.state == AuthState.error) {
          return const LoginScreen();
        }

        // Show main app if authenticated
        if (authProvider.state == AuthState.authenticated) {
          return const MainScreen();
        }

        // Fallback to login screen
        return const LoginScreen();
      },
    );
  }
}
