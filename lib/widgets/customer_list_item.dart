import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../utils/date_utils.dart';

class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final phone = customer.primaryPhone?.number ?? 'No phone';
    final email = customer.primaryEmail?.address ?? 'No email';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.fullName, style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _InfoLine(
                      icon: Icons.cake_outlined,
                      text: toDisplayDate(customer.dateOfBirth),
                      semanticLabel: 'Date of birth',
                    ),
                    _InfoLine(
                      icon: Icons.phone_outlined,
                      text: phone,
                      semanticLabel: 'Primary phone',
                    ),
                    _InfoLine(
                      icon: Icons.email_outlined,
                      text: email,
                      semanticLabel: 'Primary email',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final String semanticLabel;

  const _InfoLine({
    required this.icon,
    required this.text,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Semantics(
        label: '$semanticLabel: $text',
        excludeSemantics: true,
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
