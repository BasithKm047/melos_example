import 'app_user.dart';

abstract interface class UserRepository {
  Stream<List<AppUser>> watchUsers();

  Future<void> addUser({
    required String name,
    required String email,
    required String phone,
  });
}
