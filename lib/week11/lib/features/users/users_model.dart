import 'package:flutter/foundation.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool isSubmitting = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String name,
    required String username,
    required String email,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final draft = User(
        id: 0,
        name: name,
        username: username,
        email: email,
        phone: '1-770-736-8031',
        address: const Address(
          street: 'KBTU Street',
          suite: 'Apt. 1',
          city: 'Almaty',
          zipcode: '050000',
          geo: Geo(lat: 43.25, lng: 76.95),
        ),
        company: (name: 'KBTU', catchPhrase: 'Study hard'),
      );

      final created = await _repo.create(draft);
      items = [created, ...items];
      return true;
    } on ApiException catch (e) {
      error = e;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}