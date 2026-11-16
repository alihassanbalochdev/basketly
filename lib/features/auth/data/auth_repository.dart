import 'package:basketly/core/result/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._db);

  final SupabaseClient _db;

  bool get isSignedIn => _db.auth.currentUser != null;

  String? get email => _db.auth.currentUser?.email;

  /// Success(true): signed in.
  Future<Result<bool>> signIn(String email, String password) {
    return _run(() async {
      await _db.auth.signInWithPassword(email: email.trim(), password: password);
      return true;
    });
  }

  /// Success(true): signed in straight away.
  /// Success(false): account made, but the email must be confirmed first.
  Future<Result<bool>> signUp(String email, String password) {
    return _run(() async {
      final response = await _db.auth.signUp(email: email.trim(), password: password);
      return response.session != null;
    });
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<Result<bool>> _run(Future<bool> Function() action) async {
    try {
      return Success(await action());
    } on AuthException catch (error) {
      return Failure(error.message, cause: error);
    } on Object catch (error) {
      return Failure(
        "Couldn't reach Basketly. Check your connection and try again.",
        cause: error,
      );
    }
  }
}
