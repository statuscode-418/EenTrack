import 'package:firebase_auth/firebase_auth.dart';

import 'auth_exception.dart';
import 'auth_model.dart';
import 'authuser.dart';

class FirebaseAuthService implements AuthModel {
  late final FirebaseAuth _auth;

  static FirebaseAuthService get instance => _instance;
  FirebaseAuthService._();
  static final _instance = FirebaseAuthService._();

  @override
  Future<void> init() async {
    _auth = FirebaseAuth.instance;
  }

  @override
  Future<AuthUser?> loginWithEmail(String email, String password) async {
    try {
      final res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return _userFromFirebaseUser(res.user);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw AuthException('Unknown error');
    }
  }

  @override
  Future<AuthUser?> loginAnnonymously() async {
    try {
      final res = await _auth.signInAnonymously();
      return _userFromFirebaseUser(res.user);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw AuthException('Unknown error');
    }
  }

  @override
  Future<AuthUser?> registerWithEmail(String email, String password) async {
    try {
      final res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebaseUser(res.user);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw AuthException('Unknown error');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw AuthException('User not found');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  AuthUser? get user => _userFromFirebaseUser(_auth.currentUser);

  @override
  Future<AuthUser?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      await user.reload();
    } catch (e) {
      throw AuthException('Unknown error');
    }
    return _userFromFirebaseUser(user);
  }

  AuthUser? _userFromFirebaseUser(User? user) {
    return user != null
        ? AuthUser(
            uid: user.uid,
            email: user.email,
            isVerified: user.emailVerified,
          )
        : null;
  }

  AuthException _getAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthException('Invalid email address');
      case 'wrong-password':
        return AuthException('Wrong password');
      case 'user-not-found':
        return AuthException('User not found');
      case 'email-already-in-use':
        return AuthException('Email already in use');
      case 'weak-password':
        return AuthException('Password too weak');
      default:
        return AuthException('Unknown firebase auth error');
    }
  }

  @override
  Future<void> sendResetPasswordEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
