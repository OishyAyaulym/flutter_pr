import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    try {
      final data = await _api.get('/users');
      return [
        for (final json in data as List<dynamic>)
          User.fromJson(json as Map<String, dynamic>)
      ];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException(e.toString());
    }
  }

  Future<User> getById(int id) async {
    try {
      final data = await _api.get('/users/$id');
      return User.fromJson(data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException(e.toString());
    }
  }

  Future<User> create(User draft) async {
    try {
      final data = await _api.post('/users', draft.toJson());
      return User.fromJson(data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException(e.toString());
    }
  }
}