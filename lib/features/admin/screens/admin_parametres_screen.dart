// DriveAuto — admin_parametres_screen.dart
// Role : Paramètres de l'auto-école (stockés dans Firestore)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF7B1FA2);
const _kDark = Color(0xFF4A148C);

class AdminParametresScreen extends StatefulWidget {
  const AdminParametresScreen({super.key});

  @override
  State<AdminParametresScreen> createState() => _AdminParametresScreenState();
}

class _AdminParametresScreenState extends State<AdminParametresScreen> {
  final _nomCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _horairesCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  static const _doc =
      'auto_ecole';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _sloganCtrl.dispose();
    _telephoneCtrl.dispose();
    _emailCtrl.dispose();
    _adresseCtrl.dispose();
    _horairesCtrl.dispose();
    _siteCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('parametres')
          .doc(_doc)
          .get();
      if (snap.exists) {
        final d = snap.data()!;
        _nomCtrl.text = d['nom'] as String? ?? '';
        _sloganCtrl.text = d['slogan'] as String? ?? '';
        _telephoneCtrl.text = d['telephone'] as String? ?? '';
        _emailCtrl.text = d['email'] as String? ?? '';
        _adresseCtrl.text = d['adresse'] as String? ?? '';
        _horairesCtrl.text = d['horaires'] as String? ?? '';
        _siteCtrl.text = d['siteWeb'] as String? ?? '';
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError =
              'Impossible de charger les paramètres.\nVérifiez votre connexion et les règles Firestore.\n\nDétail : $e';
        });
      }
    }
  }

  Future<void> _sauvegarder() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('parametres')
          .doc(_doc)
          .set({
        'nom': _nomCtrl.text.trim(),
        'slogan': _sloganCtrl.text.trim(),
        'telephone': _telephoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'adresse': _adresseCtrl.text.trim(),
        'horaires': _horairesCtrl.text.trim(),
        'siteWeb': _siteCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres enregistrés !'),
            backgroundColor: _kPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_loadError != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 52, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer'),
                      style: FilledButton.styleFrom(
                          backgroundColor: _kPrimary),
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _loadError = null;
                        });
                        _charger();
                      },
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _buildSection('🏫  Identité', [
                    _field(_nomCtrl, 'Nom de l\'auto-école *',
                        Icons.business_rounded),
                    const SizedBox(height: 12),
                    _field(_sloganCtrl, 'Slogan / description',
                        Icons.format_quote_rounded,
                        maxLines: 2,
                        hint: 'Ex : Votre permis, notre priorité'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('📞  Contact', [
                    _field(_telephoneCtrl, 'Téléphone', Icons.phone_rounded,
                        type: TextInputType.phone),
                    const SizedBox(height: 12),
                    _field(_emailCtrl, 'Email', Icons.email_rounded,
                        type: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _field(_siteCtrl, 'Site web (optionnel)',
                        Icons.language_rounded,
                        type: TextInputType.url),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('📍  Localisation & horaires', [
                    _field(_adresseCtrl, 'Adresse complète',
                        Icons.location_on_rounded,
                        maxLines: 2,
                        hint: 'Ex : Avenue Kwame Nkrumah, Ouagadougou'),
                    const SizedBox(height: 12),
                    _field(_horairesCtrl, 'Horaires d\'ouverture',
                        Icons.schedule_rounded,
                        maxLines: 3,
                        hint:
                            'Ex : Lun–Ven 8h–17h\nSamedi 8h–13h\nFermé dimanche'),
                  ]),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kPrimary, _kDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _kPrimary.withValues(alpha: 0.3),
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
                        onTap: _saving ? null : _sauvegarder,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_saving)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              else
                                const Icon(Icons.save_rounded,
                                    color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _saving
                                    ? 'Enregistrement…'
                                    : 'Enregistrer les paramètres',
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, _kDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Paramètres',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Informations officielles de votre auto-école,\nvisibles par tous les apprenants.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: _kPrimary,
                letterSpacing: 0.2)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    String? hint,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: _kPrimary),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
