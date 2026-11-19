import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersModel(
        UserRepository(
          ApiClient(http.Client()),
        ),
      )..load(),
      child: MaterialApp(
        title: 'Practice 11',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const UsersScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}