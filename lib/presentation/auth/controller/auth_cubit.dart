import 'package:flutter/cupertino.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final bool isAuthenticated;
  final bool loading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.loading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAuthenticated': isAuthenticated,
      'loading': loading,
      'error': error,
    };
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      isAuthenticated: json['isAuthenticated'] ?? false,
      loading: json['loading'] ?? false,
      error: json['error'],
    );
  }
}

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(const AuthState(isAuthenticated: false, loading: false)) {
    // After hydrated state is loaded, sync with Supabase session
    // This ensures we use persisted state for quick UI, but verify with Supabase
    _syncWithSupabaseSession();
  }

  void _syncWithSupabaseSession() {
    final hasSupabaseSession =
        Supabase.instance.client.auth.currentSession != null;
    
    // If Supabase has a session but state doesn't, update state
    if (hasSupabaseSession && !state.isAuthenticated) {
      emit(state.copyWith(isAuthenticated: true, loading: false, error: null));
    }
    // If state says authenticated but Supabase doesn't have session, clear state
    else if (!hasSupabaseSession && state.isAuthenticated) {
      emit(const AuthState(isAuthenticated: false, loading: false, error: null));
    }
  }

  Future<void> login(String email, String pass) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: pass,
      );
      emit(state.copyWith(isAuthenticated: true, loading: false, error: null));
    } on AuthException catch (e) {
      emit(state.copyWith(
        loading: false,
        error: _getErrorMessage(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> signup(String email, String pass) async {
    emit(state.copyWith(loading: true, error: null));

    try {

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: pass,
      );

      debugPrint("Signup response: ${response.user}");

      if (response.user != null) {
        emit(state.copyWith(
          isAuthenticated: true,
          loading: false,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          loading: false,
          error: 'Please check your email to verify your account.',
        ));
      }
    } on AuthException catch (e) {
      emit(state.copyWith(
        loading: false,
        error: _getErrorMessage(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      emit(const AuthState(isAuthenticated: false, loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to logout. Please try again.'));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Update auth state from external source (e.g., deep link)
  void updateAuthState(bool isAuthenticated) {
    emit(state.copyWith(
      isAuthenticated: isAuthenticated,
      loading: false,
      error: null,
    ));
  }

  String _getErrorMessage(String? message) {
    if (message == null) return 'An error occurred. Please try again.';

    // Handle common Supabase error messages
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (message.contains('Email not confirmed')) {
      return 'Please verify your email before signing in.';
    } else if (message.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (message.contains('Password')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (message.contains('email')) {
      return 'Please enter a valid email address.';
    }

    return message;
  }

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    return AuthState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    return state.toJson();
  }
}
