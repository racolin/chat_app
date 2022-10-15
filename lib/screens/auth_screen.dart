import 'package:chat_app/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

enum AuthType { login, signin }

class AuthScreen extends StatefulWidget {
  static const String route = '/auth';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _key = GlobalKey<FormState>();
  var authType = AuthType.login;
  var _isLoading = false;
  final _auth = FirebaseAuth.instance;

  void changeMethod(AuthType authType) {
    setState(() {
      this.authType = authType;
      // _key.currentState?.reset();
    });
  }

  bool _validate() {
    bool result = false;
    if (_key.currentState != null) {
      result = _key.currentState!.validate();
    }
    return result;
  }

  Future<void> login(BuildContext ctx) async {
    bool val = _validate();
    if (val) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        // invalid-email:
        // Thrown if the email address is not valid.
        // user-disabled:
        // Thrown if the user corresponding to the given email has been disabled.
        // user-not-found:
        // Thrown if there is no user corresponding to the given email.
        // wrong-password:
        // Thrown if the password is invalid for the given email, or the account corresponding to the email does not have a password set.
        var mes = '';
        switch (e.code) {
          case 'invalid-email':
            mes = 'The email address is not valid.';
            break;
          case 'user-disabled':
            mes =
                'The user corresponding to the given email has been disabled.';
            break;
          case 'user-not-found':
            mes = 'There is no user corresponding to the given email.';
            break;
          case 'wrong-password':
            mes =
                'The password is invalid for the given email, or the account corresponding to the email does not have a password set.';
            break;
        }
        if (mes != '') {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mes),
            ),
          );
        }
      } on PlatformException catch (e) {
        var mes = e.message ?? 'Ohm! Please, check your cridentals';
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(mes)),
        );
      } catch (e) {
        var mes = 'Ohm! Please, check your cridentals';
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(mes)),
        );
      }
    }
  }

  Future<void> signin(BuildContext ctx) async {
    bool val = _validate();
    if (val) {
      try {
        final credentials = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        FirebaseFirestore.instance
            .collection("users")
            .doc(credentials.user?.uid)
            .set(
          {
            'username': _usernameController.text,
            'email': _emailController.text,
            'avatarUrl':
                '$baseUrlFirebase%2Fusers%2Favatars%2Fdefault_avatar.jpg',
            'chatIds': [],
          },
        );
      } on FirebaseAuthException catch (e) {
        // email-already-in-use:
        // Thrown if there already exists an account with the given email address.
        // invalid-email:
        // Thrown if the email address is not valid.
        // operation-not-allowed:
        // Thrown if email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.
        // weak-password:
        // Thrown if the password is not strong enough.
        var mes = '';
        switch (e.code) {
          case 'email-already-in-use':
            mes =
                'There already exists an account with the given email address.';
            break;
          case 'invalid-email':
            mes = 'The email address is not valid.';
            break;
          case 'operation-not-allowed:+':
            mes = 'Email/password accounts are not enabled.';
            break;
          case 'weak-password':
            mes = 'The password is not strong enough';
            break;
        }
        if (mes != '') {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mes),
            ),
          );
        }
      } on PlatformException catch (e) {
        var mes = 'Ohm! You can\'t register';
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(mes)),
        );
      }
      ;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            stops: [0.6, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: 1 / 16 * math.pi,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Text(
                    'Chat App',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(top: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (email) {
                            if (email == null || email.isEmpty) {
                              return 'Email can not empty!';
                            }
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(email);
                            if (!emailValid) {
                              return 'Not the email format!';
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (authType == AuthType.signin)
                          TextFormField(
                            controller: _usernameController,
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                            keyboardType: TextInputType.text,
                            validator: (username) {
                              if (username == null || username.isEmpty) {
                                return 'Username can not empty';
                              }
                              return null;
                            },
                          ),
                        TextFormField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validator: (password) {
                            if (password == null || password.isEmpty) {
                              return 'Password can not empty';
                            } else if (password.length < 8) {
                              return 'Password too short';
                            }
                            return null;
                          },
                        ),
                        if (authType == AuthType.signin)
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'Confirm'),
                            validator: (confirm) {
                              if (confirm == null || confirm.isEmpty) {
                                return 'Confirm can not empty';
                              }
                              if (confirm != _passwordController.text) {
                                return 'Check your password and confirm';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (!_isLoading) ...[
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              if (authType == AuthType.login) {
                                await login(context);
                              } else {
                                await signin(context);
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            },
                            child: Text(authType == AuthType.login
                                ? 'Login'
                                : 'Signin'),
                          ),
                          OutlinedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            onPressed: () {
                              changeMethod(authType == AuthType.login
                                  ? AuthType.signin
                                  : AuthType.login);
                            },
                            child: Text(authType == AuthType.signin
                                ? 'Already account'
                                : 'Create new account'),
                          ),
                        ] else
                          const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
