import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

import '../../models/user_model.dart';
import '../../services/authservices/authuser.dart';

@immutable
class AuthState {
  final String? loading;
  final String? error;
  const AuthState({
    this.loading,
    this.error,
  });

  AuthState copyWith({
    String? loading,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class AuthStateUninitialized extends AuthState {}

class AuthStateLoading extends AuthState {}

class AuthStateLoggedIn extends AuthState with EquatableMixin {
  final AuthUser authuser;
  final User user;
  final DBModel dbprovider;
  const AuthStateLoggedIn(
      {required this.authuser, required this.user, required this.dbprovider});

  @override
  List<Object?> get props => [authuser, user, dbprovider];
}

class AuthStateNeedLogin extends AuthState with EquatableMixin {
  final String email;
  final String password;
  AuthStateNeedLogin({
    this.email = '',
    this.password = '',
    super.loading,
    super.error,
  });
  @override
  List<Object?> get props => [error, loading];

  @override
  AuthStateNeedLogin copyWith({
    String? loading,
    String? error,
  }) {
    return AuthStateNeedLogin(
      email: email,
      password: password,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class AuthStateNeedRegister extends AuthState with EquatableMixin {
  final String email;
  final String password;
  AuthStateNeedRegister({
    this.email = '',
    this.password = '',
    super.loading,
    super.error,
  });
  @override
  List<Object?> get props => [error, loading];
}

class AuthStateNeedVerify extends AuthState with EquatableMixin {
  final String email;
  AuthStateNeedVerify({
    required this.email,
    super.loading,
    super.error,
  });
  @override
  List<Object?> get props => [error, loading];
}

class AuthStateShowUserDetailsForm extends AuthState {
  final User user;
  final Function(User) onSubmit;
  const AuthStateShowUserDetailsForm({
    required this.user,
    required this.onSubmit,
    super.loading,
    super.error,
  });

  @override
  AuthStateShowUserDetailsForm copyWith({
    String? loading,
    String? error,
  }) {
    return AuthStateShowUserDetailsForm(
      user: user,
      onSubmit: onSubmit,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
