import 'package:flutter/material.dart';

import '../models/address.dart';
import '../models/customer.dart';
import '../models/email.dart';
import '../models/phone.dart';
import '../utils/date_utils.dart';
import '../widgets/detail_section.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer.fullName)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DetailSection(
                  title: 'Basic Information',
                  children: [
                    LabelValueRow(
                      label: 'First Name',
                      value: customer.firstName,
                    ),
                    LabelValueRow(label: 'Last Name', value: customer.lastName),
                    LabelValueRow(
                      label: 'Date of Birth',
                      value: toDisplayDate(customer.dateOfBirth),
                    ),
                    LabelValueRow(
                      label: 'Marital Status',
                      value: customer.maritalStatus,
                    ),
                    LabelValueRow(label: 'Secure ID', value: customer.secureId),
                  ],
                ),
                DetailSection(
                  title: 'Addresses',
                  emptyText: 'No addresses on file',
                  children: [
                    for (final address in customer.addresses)
                      _AddressTile(address: address),
                  ],
                ),
                DetailSection(
                  title: 'Phones',
                  emptyText: 'No phone numbers on file',
                  children: [
                    for (final phone in customer.phones)
                      _PhoneTile(phone: phone),
                  ],
                ),
                DetailSection(
                  title: 'Emails',
                  emptyText: 'No email addresses on file',
                  children: [
                    for (final email in customer.emails)
                      _EmailTile(email: email),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;

  const _AddressTile({required this.address});

  @override
  Widget build(BuildContext context) {
    final cityLine = [
      address.city,
      address.state,
      address.zipCode,
    ].where((part) => part.isNotEmpty).join(', ');

    return ListTile(
      leading: const Icon(Icons.home_outlined),
      title: Text(address.type.isEmpty ? 'Address' : address.type),
      subtitle: Text('${address.street}\n$cityLine'),
      isThreeLine: true,
    );
  }
}

class _PhoneTile extends StatelessWidget {
  final Phone phone;

  const _PhoneTile({required this.phone});

  @override
  Widget build(BuildContext context) {
    return _ContactTile(
      icon: Icons.phone_outlined,
      value: phone.number,
      type: phone.type,
      isPrimary: phone.isPrimary,
    );
  }
}

class _EmailTile extends StatelessWidget {
  final Email email;

  const _EmailTile({required this.email});

  @override
  Widget build(BuildContext context) {
    return _ContactTile(
      icon: Icons.email_outlined,
      value: email.address,
      type: email.type,
      isPrimary: email.isPrimary,
    );
  }
}

/// Shared layout for phones and emails. The primary one is shown in bold,
/// with a coloured icon and a "Primary" badge.
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String type;
  final bool isPrimary;

  const _ContactTile({
    required this.icon,
    required this.value,
    required this.type,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isPrimary ? colors.primary : null),
      title: Text(
        value,
        style: isPrimary ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      subtitle: Text(type),
      trailing: isPrimary ? const PrimaryBadge() : null,
    );
  }
}
