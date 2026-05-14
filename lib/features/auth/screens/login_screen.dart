// DriveAuto - login_screen.dart
// Role: Interface de connexion avec email et Google Sign-In
// Auteur : DriveAuto Team

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../models/app_auth_user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted || user == null) {
      return;
    }

    await _navigateBasedOnRole(user);
  }

  Future<void> _onGoogleLogin() async {
    final user = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();
    if (!mounted || user == null) {
      return;
    }

    await _navigateBasedOnRole(user);
  }

  Future<void> _navigateBasedOnRole(AppAuthUser user) async {
    var role = user.role;
    try {
      role =
          await ref
              .read(userProfileRoleProvider.future)
              .timeout(const Duration(seconds: 2)) ??
          user.role;
    } catch (_) {
      role = user.role;
    }

    if (!mounted) return;

    if (role == 'admin') {
      context.go(AppConstants.routeAdmin);
      return;
    }

    context.go(AppConstants.routeDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authBackendLabel = ref.watch(authBackendLabelProvider);
    final isLocalAuthMode = ref.watch(isLocalAuthModeProvider);
    final googleSignInAvailable = ref.watch(googleSignInAvailableProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (!mounted || state.isLoading || !state.hasError) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppConstants.secondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 80,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DriveAuto',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous pour reprendre vos cours, quizzes et seances pratiques.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AuthBackendBanner(
                      backendLabel: authBackendLabel,
                      isLocalMode: isLocalAuthMode,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: Validators.validatePassword,
                      onFieldSubmitted: (_) => _onLogin(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => context.push(
                                AppConstants.routeForgotPassword,
                              ),
                        child: const Text('Mot de passe oublie ?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _onLogin,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Se connecter'),
                    ),
                    if (googleSignInAvailable) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text('Continuer avec Google'),
                        onPressed: authState.isLoading ? null : _onGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.push(AppConstants.routeRegister),
                      child: const Text('Nouveau ici ? Creer un compte'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackendBanner extends StatelessWidget {
  const _AuthBackendBanner({
    required this.backendLabel,
    required this.isLocalMode,
  });

  final String backendLabel;
  final bool isLocalMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocalMode
            ? Colors.orange.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isLocalMode ? Icons.info_outline : Icons.verified_user_outlined,
            color: isLocalMode ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLocalMode
                  ? 'Mode d authentification actif: $backendLabel. Creez d abord un compte sur cet appareil avant de vous connecter.'
                  : 'Mode d authentification actif: $backendLabel.',
            ),
          ),
        ],
      ),
    );
  }
}
