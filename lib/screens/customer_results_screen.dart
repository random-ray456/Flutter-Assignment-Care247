import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/customer.dart';
import '../state/customer_search_cubit.dart';
import '../state/customer_search_state.dart';
import '../widgets/customer_list_item.dart';
import '../widgets/message_view.dart';
import 'customer_detail_screen.dart';

class CustomerResultsScreen extends StatelessWidget {
  const CustomerResultsScreen({super.key});

  void _openDetails(BuildContext context, Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomerSearchCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SafeArea(
        child: BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
          builder: (context, state) {
            return switch (state) {
              SearchLoading() => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Loading...'),
                  ],
                ),
              ),
              SearchSuccess(:final customers) => RefreshIndicator(
                onRefresh: cubit.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerListItem(
                      key: ValueKey(customer.id),
                      customer: customer,
                      onTap: () => _openDetails(context, customer),
                    );
                  },
                ),
              ),
              SearchEmpty() => _RefreshableMessage(
                onRefresh: cubit.refresh,
                child: const MessageView(
                  icon: Icons.person_search,
                  title: 'No customers found',
                  message:
                      'Try different search criteria or pull down to refresh.',
                ),
              ),
              SearchError(:final message) => _RefreshableMessage(
                onRefresh: cubit.refresh,
                child: MessageView(
                  icon: Icons.cloud_off,
                  title: 'Could not load customers',
                  message: message,
                  onRetry: cubit.retry,
                ),
              ),
              SearchInitial() => const Center(
                child: MessageView(
                  icon: Icons.search,
                  title: 'No search yet',
                  message: 'Go back and enter search criteria.',
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Lets the user pull to refresh even when there is no list on screen.
class _RefreshableMessage extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _RefreshableMessage({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: child),
            ),
          );
        },
      ),
    );
  }
}
