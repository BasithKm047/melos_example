import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_repository_impl.dart';
import '../../domain/app_user.dart';
import '../../domain/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return HiveUserRepository.fromHive();
});

final userListProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchUsers();
});

final addUserControllerProvider = StateNotifierProvider<AddUserController, AsyncValue<void>>((ref) {
  return AddUserController(ref.watch(userRepositoryProvider));
});

class AddUserController extends StateNotifier<AsyncValue<void>> {
  AddUserController(this._repository) : super(const AsyncData(null));

  final UserRepository _repository;

  Future<void> addUser({required String name, required String email, required String phone}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.addUser(name: name, email: email, phone: phone),
    );
  }
}
