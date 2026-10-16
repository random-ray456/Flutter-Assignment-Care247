import 'package:flutter/material.dart';

/// A titled card used for each section on the customer detail screen.
class DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String emptyText;

  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.emptyText = 'Nothing to show',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            if (children.isEmpty)
              Padding(padding: const EdgeInsets.all(16), child: Text(emptyText))
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

/// One label / value row, e.g. "First Name   John".
class LabelValueRow extends StatelessWidget {
  final String label;
  final String value;

  const LabelValueRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "Primary" badge for the primary phone / email.
class PrimaryBadge extends StatelessWidget {
  const PrimaryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Primary',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
