import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_boxes.dart';
import '../domain/app_user.dart';
import '../domain/user_repository.dart';

class HiveUserRepository implements UserRepository {
  HiveUserRepository(this._box);

  factory HiveUserRepository.fromHive() {
    return HiveUserRepository(Hive.box<Map>(HiveBoxes.users));
  }

  final Box<Map> _box;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<AppUser>> watchUsers() async* {
    yield _readUsers();
    yield* _box.watch().map((_) => _readUsers());
  }

  @override
  Future<void> addUser({required String name, required String email, required String phone}) async {
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );

    await _box.put(user.id, user.toMap());
  }

  List<AppUser> _readUsers() {
    final users = _box.values
        .map((raw) => AppUser.fromMap(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }
}
