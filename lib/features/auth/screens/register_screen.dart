// DriveAuto - register_screen.dart
// Role: Interface de creation de compte par email avec validation
// Auteur : DriveAuto Team

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../models/app_auth_user.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Les mots de passe ne correspondent pas',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppConstants.secondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = await ref
        .read(authControllerProvider.notifier)
        .register(
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted || user == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.hasActiveSession
              ? 'Compte cree et session ouverte.'
              : 'Compte cree. Verifiez votre email puis connectez-vous.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    final authenticatedUser = ref.read(currentAuthUserProvider);
    if (authenticatedUser != null && authenticatedUser.hasActiveSession) {
      _navigateAfterRegister(authenticatedUser);
      return;
    }

    if (user.hasActiveSession) {
      _navigateAfterRegister(user);
      return;
    }

    context.go(AppConstants.routeLogin);
  }

  void _navigateAfterRegister(AppAuthUser user) {
    if (user.role == 'admin') {
      context.go(AppConstants.routeAdmin);
      return;
    }

    context.go(AppConstants.routeDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authBackendLabel = ref.watch(authBackendLabelProvider);

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
      appBar: AppBar(
        title: const Text(
          'Inscription',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rejoignez-nous',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Passez votre code et permis en toute confiance',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Backend actif: $authBackendLabel',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _displayNameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        Validators.validateRequired(value, 'Le nom complet'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmation,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: const Icon(Icons.lock_clock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmation = !_obscureConfirmation;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmation
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) => Validators.validateRequired(
                      value,
                      'La confirmation du mot de passe',
                    ),
                    onFieldSubmitted: (_) => _onRegister(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Creer mon compte',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: authState.isLoading ? null : () => context.pop(),
                    child: const Text('J ai deja un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
