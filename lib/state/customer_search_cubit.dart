import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/api_exception.dart';
import '../data/customer_repository.dart';
import 'customer_search_state.dart';

class CustomerSearchCubit extends Cubit<CustomerSearchState> {
  static const Duration retryIndicatorDuration = Duration(milliseconds: 300);

  final CustomerRepository _repository;

  Map<String, String> _lastCriteria = const {};

  // Increased on every request so an older, slower response can not
  // overwrite the result of a newer one (or a clear).
  int _requestId = 0;

  CustomerSearchCubit(this._repository) : super(const SearchInitial());

  Map<String, String> get lastCriteria => _lastCriteria;

  Future<void> search(Map<String, String> criteria) async {
    if (state is SearchLoading) return;

    _lastCriteria = Map.unmodifiable(criteria);
    emit(const SearchLoading());
    await _loadResults(forceRefresh: false);
  }

  /// Pull-to-refresh. Keeps the current list on screen while loading.
  Future<void> refresh() async {
    if (state is SearchLoading) return;
    await _loadResults(forceRefresh: true);
  }

  Future<void> retry() async {
    if (state is SearchLoading) return;

    emit(const SearchLoading());
    await _loadResults(
      forceRefresh: true,
      minimumDuration: retryIndicatorDuration,
    );
  }

  void clear() {
    _requestId++;
    _lastCriteria = const {};
    emit(const SearchInitial());
  }

  Future<void> _loadResults({
    required bool forceRefresh,
    Duration minimumDuration = Duration.zero,
  }) async {
    final requestId = ++_requestId;
    final stopwatch = Stopwatch()..start();

    CustomerSearchState newState;
    try {
      final customers = await _repository.searchCustomers(
        _lastCriteria,
        forceRefresh: forceRefresh,
      );
      newState = customers.isEmpty
          ? const SearchEmpty()
          : SearchSuccess(customers);
    } on ApiException catch (e) {
      newState = SearchError(e.message);
    } catch (_) {
      newState = const SearchError('Something went wrong. Please try again.');
    }

    final remaining = minimumDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (isClosed || requestId != _requestId) return;
    emit(newState);
  }
}
