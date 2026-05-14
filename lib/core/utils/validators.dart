/// DriveAuto — validators.dart
/// Rôle : Validateurs de champs de formulaires (email, mot de passe)
/// Auteur : DriveAuto Team
library;

class Validators {
  /// Valide un email formatté
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez renseigner votre email';
    }
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }

  /// Valide la sécurité du mot de passe (min 8 char)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez renseigner votre mot de passe';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  /// Valide qu'un champ texte standard n'est pas vide
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }
}
