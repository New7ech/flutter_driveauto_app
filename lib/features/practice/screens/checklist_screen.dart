/// DriveAuto — checklist_screen.dart
/// Rôle : Interface pour dérouler une checklist détaillée
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/practice.dart';

class ChecklistScreen extends StatefulWidget {
  final PracticeSession session;

  const ChecklistScreen({super.key, required this.session});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    // Par défaut, rien n'est coché (on peut aussi lire depuis le modèle)
    _checkedItems = List.generate(widget.session.items.length, (_) => false);
  }

  void _toggleCheck(int index) {
    setState(() {
      _checkedItems[index] = !_checkedItems[index];
    });
  }

  void _finishSession() {
    final allChecked = _checkedItems.every((e) => e == true);
    if (!allChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attention, toutes les étapes ne sont pas cochées !'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session pratique validée ! Excellent travail.'),
          backgroundColor: Colors.green,
        ),
      );
      // En production : On mettrait à jour Firestore via un Provider
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _checkedItems.where((e) => e == true).length /
        widget.session.items.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.session.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
              background: widget.session.imageUrl != null
                  ? Image.network(
                      widget.session.imageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.4),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(color: AppConstants.primaryColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progression',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${(_checkedItems.where((e) => e).length)} / ${widget.session.items.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    color: AppConstants.secondaryColor,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = widget.session.items[index];
              final isChecked = _checkedItems[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Material(
                  elevation: isChecked ? 0 : 2,
                  color: isChecked
                      ? (isDark ? Colors.grey.shade900 : Colors.grey.shade100)
                      : (isDark ? AppConstants.cardColorDark : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _toggleCheck(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                              value: isChecked,
                              activeColor: AppConstants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) => _toggleCheck(index),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.task,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isChecked
                                        ? Colors.grey
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.detail,
                                  style: TextStyle(
                                    color: isChecked
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }, childCount: widget.session.items.length),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Valider la Séance'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _finishSession,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
