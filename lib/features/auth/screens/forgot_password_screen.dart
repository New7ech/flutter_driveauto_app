// DriveAuto — forgot_password_screen.dart
// Role: Réinitialisation du mot de passe (Firebase = email, Local = reset direct)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

enum _Etape { saisieEmail, localReset, successFirebase, successLocal }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePw = true;
  bool _obscureConfirm = true;

  _Etape _etape = _Etape.saisieEmail;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _envoyerEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();

    final success = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email);

    if (!mounted) return;

    if (success) {
      setState(() => _etape = _Etape.successFirebase);
      return;
    }

    // Vérifier si l'erreur indique le mode local
    final error = ref.read(authControllerProvider).error?.toString() ?? '';
    if (error == 'local-mode') {
      setState(() => _etape = _Etape.localReset);
    }
    // Sinon l'erreur est affichée via ref.listen
  }

  Future<void> _reinitialiserLocal() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetLocalPassword(
          email: _emailCtrl.text.trim(),
          newPassword: _pwCtrl.text,
        );

    if (!mounted) return;
    if (success) setState(() => _etape = _Etape.successLocal);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (!mounted || state.isLoading || !state.hasError) return;
      final msg = state.error.toString();
      if (msg == 'local-mode') return; // traité en interne
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: AppConstants.secondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: switch (_etape) {
                _Etape.saisieEmail => _buildEmailForm(authState),
                _Etape.localReset => _buildLocalResetForm(authState),
                _Etape.successFirebase => _buildSuccessFirebase(),
                _Etape.successLocal => _buildSuccessLocal(),
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFF005C38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 24),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () {
                  if (_etape == _Etape.localReset) {
                    setState(() => _etape = _Etape.saisieEmail);
                  } else {
                    context.pop();
                  }
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mot de passe oublié',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    switch (_etape) {
                      _Etape.localReset => 'Créer un nouveau mot de passe',
                      _Etape.successFirebase ||
                      _Etape.successLocal =>
                        'Réinitialisation terminée',
                      _ => 'Réinitialisez votre accès',
                    },
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Étape 1 : Saisie email ─────────────────────────────────────────────────

  Widget _buildEmailForm(AsyncValue<void> authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                size: 40, color: AppConstants.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Entrez votre adresse email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Si votre compte est connecté à Firebase, un email de réinitialisation vous sera envoyé.\nSinon, vous pourrez définir un nouveau mot de passe directement.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 32),
        Form(
          key: _emailFormKey,
          child: _buildTextField(
            controller: _emailCtrl,
            label: 'Adresse email',
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
        ),
        const SizedBox(height: 28),
        _buildGradientButton(
          label: authState.isLoading ? 'Vérification…' : 'Continuer',
          icon: authState.isLoading ? null : Icons.arrow_forward_rounded,
          loading: authState.isLoading,
          onTap: _envoyerEmail,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Retour à la connexion',
              style: TextStyle(color: AppConstants.primaryColor)),
        ),
      ],
    );
  }

  // ── Étape 2 : Reset local (mode Hive) ─────────────────────────────────────

  Widget _buildLocalResetForm(AsyncValue<void> authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Explication mode local
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Votre compte est enregistré localement sur cet appareil. '
                  'Définissez un nouveau mot de passe ci-dessous — aucun email n\'est nécessaire.',
                  style: TextStyle(fontSize: 13, color: Colors.orange, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Nouveau mot de passe',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Compte : ${_emailCtrl.text.trim()}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 20),
        Form(
          key: _resetFormKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _pwCtrl,
                label: 'Nouveau mot de passe (min. 6 caractères)',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePw,
                onToggleObscure: () =>
                    setState(() => _obscurePw = !_obscurePw),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return 'Minimum 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _confirmCtrl,
                label: 'Confirmer le mot de passe',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v != _pwCtrl.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildGradientButton(
          label: authState.isLoading ? 'Enregistrement…' : 'Enregistrer',
          icon: authState.isLoading ? null : Icons.check_rounded,
          loading: authState.isLoading,
          onTap: _reinitialiserLocal,
        ),
      ],
    );
  }

  // ── Succès Firebase ────────────────────────────────────────────────────────

  Widget _buildSuccessFirebase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded,
                size: 46, color: AppConstants.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Email envoyé !',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Un lien de réinitialisation a été envoyé à :',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 6),
        Text(
          _emailCtrl.text.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: const Column(
            children: [
              _InfoRow(
                  icon: Icons.folder_outlined,
                  text: 'Vérifiez aussi le dossier Spam / Courrier indésirable.'),
              SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.timer_outlined,
                  text: 'Le lien expire dans 1 heure.'),
              SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.email_outlined,
                  text:
                      'L\'email vient de noreply@driveauto-ed6b7.firebaseapp.com'),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Retour à la connexion'),
          style: FilledButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => context.go(AppConstants.routeLogin),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _envoyerEmail,
          child: Text('Renvoyer l\'email',
              style: TextStyle(color: Colors.grey.shade500)),
        ),
      ],
    );
  }

  // ── Succès Local ───────────────────────────────────────────────────────────

  Widget _buildSuccessLocal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_open_rounded,
                size: 46, color: AppConstants.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mot de passe mis à jour !',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Se connecter'),
          style: FilledButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => context.go(AppConstants.routeLogin),
        ),
      ],
    );
  }

  // ── Widgets helpers ────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: AppConstants.primaryColor, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    IconData? icon,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFF005C38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else if (icon != null)
                  Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: Colors.blue)),
        ),
      ],
    );
  }
}
