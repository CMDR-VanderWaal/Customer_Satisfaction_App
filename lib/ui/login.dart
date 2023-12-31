import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

import 'mainHome.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  //final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final Box _boxLogin = Hive.box("login");
  // final Box _boxAccounts = Hive.box("accounts");

  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text.toString(),
      );
      // final Box _boxLogin = await Hive.openBox("login");
      // await _boxLogin.put("loginStatus", true);
      //print("Login successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Home(), // Navigate to Home upon successful login.
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(
        () {
          errorMessage = e.message;
        },
      );
    }
  }

  Future<void> createUserWithEmailPasseord() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _passwordField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (isLogin) {
          signInWithEmailAndPassword(context);
        } else {
          createUserWithEmailPasseord();
        }
      },
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register Instead' : 'Login Instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_boxLogin.get("loginStatus") ?? false) {
      return Home();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Login to your account",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),
              // TextFormField(
              //   controller: _controllerUsername,
              //   keyboardType: TextInputType.name,
              //   decoration: InputDecoration(
              //     labelText: "Username",
              //     prefixIcon: const Icon(Icons.person_outline),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   onEditingComplete: () => _focusNodePassword.requestFocus(),
              //   validator: (String? value) {
              //     if (value == null || value.isEmpty) {
              //       return "Please enter username.";
              //     } else if (!_boxAccounts.containsKey(value)) {
              //       return "Username is not registered.";
              //     }

              //     return null;
              //   },
              // ),
              _entryField('Email', _controllerEmail),
              _passwordField('Password', _controllerPassword),

              const SizedBox(height: 10),
              // TextFormField(
              //   controller: _controllerPassword,
              //   focusNode: _focusNodePassword,
              //   obscureText: _obscurePassword,
              //   keyboardType: TextInputType.visiblePassword,
              //   decoration: InputDecoration(
              //     labelText: "Password",
              //     prefixIcon: const Icon(Icons.password_outlined),
              //     suffixIcon: IconButton(
              //         onPressed: () {
              //           setState(() {
              //             _obscurePassword = !_obscurePassword;
              //           });
              //         },
              //         icon: _obscurePassword
              //             ? const Icon(Icons.visibility_outlined)
              //             : const Icon(Icons.visibility_off_outlined)),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   validator: (String? value) {
              //     if (value == null || value.isEmpty) {
              //       return "Please enter password.";
              //     } else if (value !=
              //         _boxAccounts.get(_controllerUsername.text)) {
              //       return "Wrong password.";
              //     }

              //     return null;
              //   },
              // ),
              _errorMessage(),
              _submitButton(),
              // const SizedBox(height: 60),
              // Column(
              //   children: [
              //     ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //         minimumSize: const Size.fromHeight(50),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20),
              //         ),
              //       ),
              //       onPressed: () {
              //         if (_formKey.currentState?.validate() ?? false) {
              //           _boxLogin.put("loginStatus", true);
              //           _boxLogin.put("userName", _controllerUsername.text);

              //           Navigator.pushReplacement(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) {
              //                 return Home();
              //               },
              //             ),
              //           );
              //         }
              //       },
              //       child: const Text("Login"),
              //     ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text("Don't have an account?"),
              //     TextButton(
              //       onPressed: () {
              //         _formKey.currentState?.reset();

              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) {
              //               return const Signup();
              //             },
              //           ),
              //         );
              //       },
              //       child: const Text("Signup"),
              //     ),
              //   ],
              // ),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
