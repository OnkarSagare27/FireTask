import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _userSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    _userSubscription = _authRepository.user.listen((user) {
      add(AuthUserChanged(user));
    });

    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogInRequested>(_onLogInRequested);
    on<AuthLogOutRequested>(_onLogOutRequested);
    on<AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogInRequested(
    AuthLogInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logIn(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogOutRequested(
    AuthLogOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  String _getAuthErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No user found with this email address.';
    case 'wrong-password':
    case 'INVALID_LOGIN_CREDENTIALS':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'The email address is already in use by another account.';
    case 'weak-password':
      return 'The password provided is too weak.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please wait a moment and try again.';
    case 'user-token-expired':
      return 'Your session has expired. Please log in again.';
    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled. Please contact support.';
    default:
      return 'Authentication failed. Please try again.';
  }
}


  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
