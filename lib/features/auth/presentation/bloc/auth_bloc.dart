import 'dart:async';
import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    
    // Set up auth state changes stream
    _authSubscription = authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          developer.log('Stream user authenticated: ${user.id}, email: ${user.email}');
          add(AuthUserChanged(user: user));
        } else {
          developer.log('Stream user unauthenticated');
          add(AuthUserChanged(user: null));
        }
      },
      onError: (error) {
        developer.log('Auth stream error: $error');
        add(AuthErrorOccurred(message: error.toString()));
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Check current user immediately
    final currentUser = authRepository.getCurrentUser();
    if (currentUser != null) {
      developer.log('Current user found: ${currentUser.id}, email: ${currentUser.email}');
      emit(Authenticated(user: currentUser));
    } else {
      developer.log('No current user found');
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      developer.log('AuthUserChanged - Emitting Authenticated for user: ${event.user!.id}');
      emit(Authenticated(user: event.user!));
    } else {
      developer.log('AuthUserChanged - Emitting Unauthenticated');
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthErrorOccurred(
    AuthErrorOccurred event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthError(message: event.message));
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      developer.log('Sign up successful for user: ${user.id}');
      // The auth state stream will handle the state change
    } catch (e) {
      developer.log('Sign up error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      developer.log('Sign in successful for user: ${user.id}');
      // The auth state stream will handle the state change
    } catch (e) {
      developer.log('Sign in error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      developer.log('Sign out successful');
      // The auth state stream will handle the state change
    } catch (e) {
      developer.log('Sign out error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
