import 'package:customer_search/state/customer_search_cubit.dart';
import 'package:customer_search/state/customer_search_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_data.dart';

// Cubit streams deliver events asynchronously, so give listeners a turn.
Future<void> waitForStreamEvents() => Future<void>.delayed(Duration.zero);

void main() {
  group('CustomerSearchCubit', () {
    test('search emits loading then success', () async {
      final cubit = CustomerSearchCubit(FakeServer().repository);
      final states = <CustomerSearchState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.search({'firstName': 'john'});
      await waitForStreamEvents();

      expect(states.length, 2);
      expect(states[0], isA<SearchLoading>());
      expect(states[1], isA<SearchSuccess>());
      expect((states[1] as SearchSuccess).customers.single.firstName, 'John');

      await subscription.cancel();
      await cubit.close();
    });

    test('network failure emits an error, then retry succeeds', () async {
      final server = FakeServer(throwNetworkError: true);
      final cubit = CustomerSearchCubit(server.repository);

      await cubit.search({'lastName': 'smith'});
      expect(cubit.state, isA<SearchError>());

      server.throwNetworkError = false;
      await cubit.retry();

      expect(cubit.state, isA<SearchSuccess>());
      await cubit.close();
    });
  });
}
