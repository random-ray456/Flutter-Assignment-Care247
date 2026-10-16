import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/field_config.dart';
import '../config/search_config.dart';
import '../state/customer_search_cubit.dart';
import '../state/customer_search_state.dart';
import '../widgets/dynamic_search_form.dart';
import 'customer_results_screen.dart';

class CustomerSearchScreen extends StatefulWidget {
  final List<FieldConfig> fields;

  const CustomerSearchScreen({super.key, this.fields = searchConfig});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  Future<void> _onSearch(Map<String, String> criteria) async {
    final cubit = context.read<CustomerSearchCubit>();
    await cubit.search(criteria);
    _openResultsIfReady(cubit.state);
  }

  Future<void> _onRetry() async {
    final cubit = context.read<CustomerSearchCubit>();
    await cubit.retry();
    _openResultsIfReady(cubit.state);
  }

  void _openResultsIfReady(CustomerSearchState state) {
    // The user may have left this screen while the request was running.
    if (!mounted) return;
    if (state is SearchSuccess || state is SearchEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CustomerResultsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap outside a field to hide the keyboard.
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Customer Search')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    'Fill in one or more fields to find a customer.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
                    builder: (context, state) {
                      if (state is SearchLoading) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading...'),
                            ],
                          ),
                        );
                      }
                      if (state is! SearchError) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SearchErrorCard(
                          message: state.message,
                          onRetry: _onRetry,
                        ),
                      );
                    },
                  ),
                  BlocSelector<CustomerSearchCubit, CustomerSearchState, bool>(
                    selector: (state) => state is SearchLoading,
                    builder: (context, isLoading) {
                      return DynamicSearchForm(
                        fields: widget.fields,
                        isLoading: isLoading,
                        onSearch: _onSearch,
                        onClear: context.read<CustomerSearchCubit>().clear,
                      );
                    },
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

class _SearchErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SearchErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(top: 24),
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
