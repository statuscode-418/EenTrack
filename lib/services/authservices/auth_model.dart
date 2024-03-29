import 'authuser.dart';

abstract class AuthModel {
  Future<void> init();
  AuthUser? get user;
  Future<AuthUser?> get currentUser;
  Future<AuthUser?> loginWithEmail(String email, String password);
  Future<AuthUser?> loginAnnonymously();
  Future<AuthUser?> registerWithEmail(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> sendResetPasswordEmail(String email);
  Future<void> logout();
}
