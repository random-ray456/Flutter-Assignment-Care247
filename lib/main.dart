import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'data/customer_api.dart';
import 'data/customer_repository.dart';
import 'screens/customer_search_screen.dart';
import 'state/customer_search_cubit.dart';

void main() {
  final repository = CustomerRepository(CustomerApi(client: http.Client()));
  runApp(CustomerSearchApp(repository: repository));
}

class CustomerSearchApp extends StatelessWidget {
  final CustomerRepository repository;

  const CustomerSearchApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerSearchCubit(repository),
      child: MaterialApp(
        title: 'Care247 Customer Search',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const CustomerSearchScreen(),
      ),
    );
  }
}
