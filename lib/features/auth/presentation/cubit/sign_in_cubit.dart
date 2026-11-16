import 'package:basketly/core/result/result.dart';
import 'package:basketly/features/auth/data/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInState extends Equatable {
  const SignInState({
    this.creatingAccount = false,
    this.submitting = false,
    this.error,
    this.info,
  });

  final bool creatingAccount; // false = sign in, true = create account
  final bool submitting;
  final String? error;
  final String? info; // e.g. "check your email"

  @override
  List<Object?> get props => [creatingAccount, submitting, error, info];
}

/// Signing in itself is enough: the router hears about the new session
/// and moves on to wherever the person was going.
class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._auth) : super(const SignInState());

  final AuthRepository _auth;

  void toggleMode() => emit(SignInState(creatingAccount: !state.creatingAccount));

  Future<void> submit(String email, String password) async {
    final creating = state.creatingAccount;
    emit(SignInState(creatingAccount: creating, submitting: true));

    final result = creating
        ? await _auth.signUp(email, password)
        : await _auth.signIn(email, password);
    if (isClosed) return;

    emit(switch (result) {
      Success(value: true) => SignInState(creatingAccount: creating),
      Success() => const SignInState(
          info: 'Account created. Confirm the link in your email, then sign in.',
        ),
      Failure(:final message) => SignInState(creatingAccount: creating, error: message),
    });
  }
}
