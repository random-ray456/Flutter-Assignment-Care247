import '../models/customer.dart';

sealed class CustomerSearchState {
  const CustomerSearchState();
}

class SearchInitial extends CustomerSearchState {
  const SearchInitial();
}

class SearchLoading extends CustomerSearchState {
  const SearchLoading();
}

class SearchSuccess extends CustomerSearchState {
  final List<Customer> customers;

  const SearchSuccess(this.customers);
}

class SearchEmpty extends CustomerSearchState {
  const SearchEmpty();
}

class SearchError extends CustomerSearchState {
  final String message;

  const SearchError(this.message);
}
