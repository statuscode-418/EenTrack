import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/services/dbservice/db_exception.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../firebase_options.dart';
import '../../services/authservices/auth_exception.dart';
import '../../services/authservices/auth_model.dart';
import 'auth_events.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthModel authProvider, DBModel dbprovider)
      : super(AuthStateUninitialized()) {
    // Initialize the app
    on<AuthEventInit>(
      (event, emit) async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        await authProvider.init();
        await dbprovider.init();

        final authuser = authProvider.user;
        if (authuser == null) {
          emit(AuthStateNeedLogin());
          return;
        }
        if ((authuser.isVerified ?? false) == false) {
          emit(AuthStateNeedVerify(
            email: authuser.email!,
          ));
          return;
        }
        var user = await dbprovider.getUser(authuser.uid);
        if (user == null) {
          user = User.newUser(email: authuser.email!, uid: authuser.uid);
          emit(AuthStateShowUserDetailsForm(
            user: user,
            onSubmit: (u) => add(AuthEventAddUserDetails(user: u)),
          ));
          return;
        }
        emit(AuthStateLoggedIn(
          authuser: authuser,
          user: user,
          dbprovider: dbprovider,
        ));
      },
    );

    // Need login event
    on<AuthEventShowLogin>(
      (event, emit) {
        final email = event.email;
        final password = event.password;

        emit(AuthStateNeedLogin(
          email: email,
          password: password,
        ));
      },
    );

    // Need register event
    on<AuthEventShowRegister>(
      (event, emit) {
        final email = event.email;
        final password = event.password;
        emit(AuthStateNeedRegister(
          email: email,
          password: password,
        ));
      },
    );

    // Show verify event
    on<AuthEventShowVerifyEmail>((event, emit) {
      emit(AuthStateNeedVerify(
        email: event.email,
      ));
    });

    // Login Event
    on<AuthEventLogin>((event, emit) async {
      var email = event.email;
      var password = event.password;
      emit(AuthStateNeedLogin(
        email: email,
        password: password,
        loading: 'Logging in...',
      ));

      try {
        var authuser = await authProvider.loginWithEmail(email, password);
        if (authuser == null) {
          emit(AuthStateNeedLogin(
            email: email,
            password: password,
            error: 'Invalid email or password',
          ));
          return;
        }
        if (!(authuser.isVerified ?? false)) {
          emit(AuthStateNeedVerify(
            email: authuser.email!,
          ));
          return;
        }
        var user = await dbprovider.getUser(authuser.uid);
        if (user == null) {
          user = User.newUser(uid: authuser.uid, email: authuser.email!);
          emit(AuthStateShowUserDetailsForm(
            user: user,
            onSubmit: (u) => add(AuthEventAddUserDetails(user: u)),
          ));
          return;
        }
        emit(AuthStateLoggedIn(
          authuser: authuser,
          user: user,
          dbprovider: dbprovider,
        ));
      } on AuthException catch (e) {
        emit(AuthStateNeedLogin(
          email: email,
          password: password,
          error: e.message,
        ));
      }
    });

    // Register Event
    on<AuthEventRegister>((event, emit) async {
      var email = event.email;
      var password = event.password;
      emit(AuthStateNeedRegister(
        email: email,
        password: password,
        loading: 'Registering...',
      ));
      try {
        var user = await authProvider.registerWithEmail(email, password);
        if (user == null) {
          emit(AuthStateNeedRegister(
            email: email,
            password: password,
            error: 'Invalid email or password',
          ));
          return;
        }
        emit(AuthStateNeedVerify(
          email: user.email!,
        ));
      } on AuthException catch (e) {
        emit(AuthStateNeedRegister(
          email: email,
          password: password,
          error: e.message,
        ));
      }
    });

    // Event Logout
    on<AuthEventLogout>((event, emit) async {
      emit(AuthStateNeedLogin(loading: 'Logging out...'));
      try {
        await authProvider.logout();
      } on AuthException catch (e) {
        emit(AuthStateNeedLogin(error: e.toString()));
      } catch (e) {
        emit(AuthStateNeedLogin(error: 'Something went wrong...'));
      }
      emit(AuthStateNeedLogin());
    });

    // Send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      var user = authProvider.user;
      if (user == null) {
        return emit(AuthStateNeedLogin(error: 'User not found'));
      }
      emit(AuthStateNeedVerify(
          email: user.email!, loading: 'Sending verification email...'));
      await authProvider.sendEmailVerification();
      emit(AuthStateNeedVerify(
        email: user.email!,
      ));
    });

    // Verify email
    on<AuthEventVerifyEmail>((event, emit) async {
      var authuser = authProvider.user;

      if (authuser == null) {
        return emit(AuthStateNeedLogin(error: 'User not found'));
      }

      emit(AuthStateNeedVerify(
          email: authuser.email!, loading: 'Verifying email...'));
      try {
        authuser = await authProvider.currentUser;
        if (authuser == null) {
          emit(AuthStateNeedLogin(error: 'User not found'));
          return;
        }
        if ((authuser.isVerified ?? false) == false) {
          emit(AuthStateNeedVerify(
              email: authuser.email!, error: 'Email not verified'));
          return;
        }
        var user = await dbprovider.getUser(authuser.uid);
        if (user == null) {
          user = User.newUser(uid: authuser.uid, email: authuser.email!);
          emit(AuthStateShowUserDetailsForm(
            user: user,
            onSubmit: (u) => add(AuthEventAddUserDetails(user: u)),
          ));
          return;
        }
        emit(AuthStateLoggedIn(
          authuser: authuser,
          user: user,
          dbprovider: dbprovider,
        ));
      } on AuthException catch (e) {
        emit(AuthStateNeedVerify(email: 'Unknown Email', error: e.message));
      }
    });

    on<AuthEventAddUserDetails>(
      (event, emit) {
        var state = this.state;
        if (state is! AuthStateShowUserDetailsForm) {
          return;
        }
        emit(state.copyWith(loading: 'Adding user details...'));
        try {
          var authuser = authProvider.user!;
          var user = state.user;

          dbprovider.createUser(user);
          emit(AuthStateLoggedIn(
            authuser: authuser,
            user: user,
            dbprovider: dbprovider,
          ));
        } on DBException catch (e) {
          emit(state.copyWith(
            error: e.message,
          ));
        } catch (e) {
          emit(state.copyWith(
            error: 'Something went wrong...',
          ));
        }
      },
    );

    on<AuthEventShowUpdateUserDetails>(
      (event, emit) {
        emit(AuthStateShowUserDetailsForm(
          user: event.user,
          onSubmit: (user) => add(
            AuthEventUpdateUserDetails(user: user),
          ),
        ));
      },
    );

    on<AuthEventUpdateUserDetails>(
      (event, emit) {
        var user = event.user;
        dbprovider.updateUser(user);
        emit(
          AuthStateLoggedIn(
            authuser: authProvider.user!,
            user: user,
            dbprovider: dbprovider,
          ),
        );
      },
    );

    on<AuthEventResetPassword>(
      (event, emit) {
        if (state is! AuthStateNeedLogin) return;
        emit(state.copyWith(loading: "Sending reset password email..."));
        try {
          authProvider.sendResetPasswordEmail(event.email);
          emit(AuthStateNeedLogin(email: event.email));
        } on DBException catch (e) {
          emit(AuthStateNeedLogin(email: event.email, error: e.message));
        } catch (e) {
          emit(AuthStateNeedLogin(email: event.email, error: e.toString()));
        }
      },
    );
  }
}
