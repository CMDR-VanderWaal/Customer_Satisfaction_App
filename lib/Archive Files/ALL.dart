// main.dart: -  

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// //import 'package:path_provider/path_provider.dart';

// import 'main_app.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase
//       .initializeApp(); // need to have this to make app work with firebase
//   await _initHive();
//   //final applicationDocumentDir = await getApplicationDocumentsDirectory();
//   //print(applicationDocumentDir);
//   runApp(const MainApp());
// }

// Future<void> _initHive() async {
//   await Hive.initFlutter();
//   await Hive.openBox("login");
//   //final box = await Hive.openBox('login');
//   //print(box.path);
//   await Hive.openBox("accounts");
// }

// main_app.dart : 
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:login_flutter/widget_tree.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'ui/login.dart';

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.from(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
//         ),
//       ),
//       home: const WidgetTree(),
//     );
//   }
// }

// // class ToLogin extends StatefulWidget {
// //   const ToLogin({super.key});

// //   @override
// //   State<ToLogin> createState() => _ToLoginState();
// // }

// // class _ToLoginState extends State<ToLogin> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Login();
// //   }
// // }

// widget_tree.dart : 

// import 'dart:io';

// import 'package:login_flutter/auth.dart';
// import 'package:login_flutter/ui/mainHome.dart';
// import 'package:login_flutter/ui/login.dart';
// import 'package:flutter/material.dart';

// class WidgetTree extends StatefulWidget {
//   const WidgetTree({super.key});

//   @override
//   State<WidgetTree> createState() => _WidgetTreeState();
// }

// class _WidgetTreeState extends State<WidgetTree> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: Auth().authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Home();
//         } else {
//           return Login();
//         }
//       },
//     );
//   }
// }


// auth.dart : 

// import 'package:firebase_auth/firebase_auth.dart';

// class Auth {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   User? get currentUser => _firebaseAuth.currentUser;

//   Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

//   Future<void> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     await _firebaseAuth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   Future<void> createUserWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     await _firebaseAuth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//   }
// }

// login.dart : 


// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../auth.dart';

// import 'mainHome.dart';
// import 'signup.dart';

// class Login extends StatefulWidget {
//   Login({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final GlobalKey<FormState> _formKey = GlobalKey();

//   final FocusNode _focusNodePassword = FocusNode();
//   final TextEditingController _controllerUsername = TextEditingController();
//   //final TextEditingController _controllerPassword = TextEditingController();

//   bool _obscurePassword = true;
//   final Box _boxLogin = Hive.box("login");
//   final Box _boxAccounts = Hive.box("accounts");

//   String? errorMessage = '';
//   bool isLogin = true;

//   final TextEditingController _controllerEmail = TextEditingController();
//   final TextEditingController _controllerPassword = TextEditingController();

//   Future<void> signInWithEmailAndPassword() async {
//     try {
//       await Auth().signInWithEmailAndPassword(
//         email: _controllerEmail.text,
//         password: _controllerPassword.text.toString(),
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         errorMessage = e.message;
//       });
//     }
//   }

//   Future<void> createUserWithEmailPasseord() async {
//     try {
//       await Auth().createUserWithEmailAndPassword(
//         email: _controllerEmail.text,
//         password: _controllerPassword.text,
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         errorMessage = e.message;
//       });
//     }
//   }

//   Widget _title() {
//     return const Text('Firebase Auth');
//   }

//   Widget _entryField(
//     String title,
//     TextEditingController controller,
//   ) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: title,
//       ),
//     );
//   }

//   Widget _errorMessage() {
//     return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
//   }

//   Widget _submitButton() {
//     return ElevatedButton(
//       onPressed:
//           isLogin ? signInWithEmailAndPassword : createUserWithEmailPasseord,
//       child: Text(isLogin ? 'Login' : 'Register'),
//     );
//   }

//   Widget _loginOrRegisterButton() {
//     return TextButton(
//       onPressed: () {
//         setState(() {
//           isLogin = !isLogin;
//         });
//       },
//       child: Text(isLogin ? 'Register Instead' : 'Login Instead'),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_boxLogin.get("loginStatus") ?? false) {
//       return Home();
//     }

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 150),
//               Text(
//                 "Welcome back",
//                 style: Theme.of(context).textTheme.headlineLarge,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Login to your account",
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 60),
//               // TextFormField(
//               //   controller: _controllerUsername,
//               //   keyboardType: TextInputType.name,
//               //   decoration: InputDecoration(
//               //     labelText: "Username",
//               //     prefixIcon: const Icon(Icons.person_outline),
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10),
//               //     ),
//               //     enabledBorder: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10),
//               //     ),
//               //   ),
//               //   onEditingComplete: () => _focusNodePassword.requestFocus(),
//               //   validator: (String? value) {
//               //     if (value == null || value.isEmpty) {
//               //       return "Please enter username.";
//               //     } else if (!_boxAccounts.containsKey(value)) {
//               //       return "Username is not registered.";
//               //     }

//               //     return null;
//               //   },
//               // ),
//               _entryField('Email', _controllerEmail),
//               _entryField('Password', _controllerPassword),
//               const SizedBox(height: 10),
//               // TextFormField(
//               //   controller: _controllerPassword,
//               //   focusNode: _focusNodePassword,
//               //   obscureText: _obscurePassword,
//               //   keyboardType: TextInputType.visiblePassword,
//               //   decoration: InputDecoration(
//               //     labelText: "Password",
//               //     prefixIcon: const Icon(Icons.password_outlined),
//               //     suffixIcon: IconButton(
//               //         onPressed: () {
//               //           setState(() {
//               //             _obscurePassword = !_obscurePassword;
//               //           });
//               //         },
//               //         icon: _obscurePassword
//               //             ? const Icon(Icons.visibility_outlined)
//               //             : const Icon(Icons.visibility_off_outlined)),
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10),
//               //     ),
//               //     enabledBorder: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(10),
//               //     ),
//               //   ),
//               //   validator: (String? value) {
//               //     if (value == null || value.isEmpty) {
//               //       return "Please enter password.";
//               //     } else if (value !=
//               //         _boxAccounts.get(_controllerUsername.text)) {
//               //       return "Wrong password.";
//               //     }

//               //     return null;
//               //   },
//               // ),
//               _errorMessage(),
//               _submitButton(),
//               // const SizedBox(height: 60),
//               // Column(
//               //   children: [
//               //     ElevatedButton(
//               //       style: ElevatedButton.styleFrom(
//               //         minimumSize: const Size.fromHeight(50),
//               //         shape: RoundedRectangleBorder(
//               //           borderRadius: BorderRadius.circular(20),
//               //         ),
//               //       ),
//               //       onPressed: () {
//               //         if (_formKey.currentState?.validate() ?? false) {
//               //           _boxLogin.put("loginStatus", true);
//               //           _boxLogin.put("userName", _controllerUsername.text);

//               //           Navigator.pushReplacement(
//               //             context,
//               //             MaterialPageRoute(
//               //               builder: (context) {
//               //                 return Home();
//               //               },
//               //             ),
//               //           );
//               //         }
//               //       },
//               //       child: const Text("Login"),
//               //     ),
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.center,
//               //   children: [
//               //     const Text("Don't have an account?"),
//               //     TextButton(
//               //       onPressed: () {
//               //         _formKey.currentState?.reset();

//               //         Navigator.push(
//               //           context,
//               //           MaterialPageRoute(
//               //             builder: (context) {
//               //               return const Signup();
//               //             },
//               //           ),
//               //         );
//               //       },
//               //       child: const Text("Signup"),
//               //     ),
//               //   ],
//               // ),
//               _loginOrRegisterButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _focusNodePassword.dispose();
//     _controllerUsername.dispose();
//     _controllerPassword.dispose();
//     super.dispose();
//   }
// }


// mainHome.dart : 

// import "package:flutter/material.dart";
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:login_flutter/ui/overallReport.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:login_flutter/auth.dart';

// import "login.dart";
// import 'customerWise.dart';
// import 'overallReport.dart';

// class Home extends StatelessWidget {
//   Home({Key? key}) : super(key: key);

//   final Box _boxLogin = Hive.box("login");
//   final User? user = Auth().currentUser;

//   Future<void> signOut() async {
//     await Auth().signOut();
//   }

//   Widget _title() {
//     return const Text('Firebas Auth');
//   }

//   Widget _userUid() {
//     return Text(user?.email ?? 'User email');
//   }

//   Widget _signOutButton() {
//     return ElevatedButton(
//       onPressed: signOut,
//       child: const Text('Sign Out'),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = (MediaQuery.of(context).size.height);
//     double height = (MediaQuery.of(context).size.height);
//     double containerWidth = 0.45 * width;
//     double containerHeight = 0.8 * height;
//     double rowButtonH = containerHeight * .25;
//     double rowButtonW = containerWidth * .39;
//     double buttonFontSize = containerHeight * 0.1;
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//       appBar: AppBar(
//         title: Row(
//           children: <Widget>[
//             _userUid(),
//           ],
//         ),
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white),
//               ),
//               child: IconButton(
//                 onPressed: () {
//                   signOut;
//                   _boxLogin.clear();
//                   _boxLogin.put("loginStatus", false);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return Login();
//                       },
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.logout_rounded),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Center(
//         child: Container(
//           width: containerWidth,
//           height: containerHeight,
//           //color: const Color.fromARGB(255, 205, 19, 19),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: width * 0.29,
//                 height: height * 0.25,
//                 child: Center(
//                   child: Text(
//                     'Welcome Employee name',
//                     style: TextStyle(fontSize: height / 25),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       height: rowButtonH,
//                       width: rowButtonW,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         onPressed: () {
//                           //print('Row Button 1');
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) {
//                                 return const CustomerWise();
//                               },
//                             ),
//                           );
//                         },
//                         child: Text(
//                           'Customer Wise Report',
//                           style: TextStyle(fontSize: buttonFontSize * .35),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       height: rowButtonH,
//                       width: rowButtonW,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         onPressed: () {
//                           //print('Row Button 2');
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) {
//                                 return const OverallReport();
//                               },
//                             ),
//                           );
//                         },
//                         child: Text(
//                           "Overall Report",
//                           style: TextStyle(fontSize: buttonFontSize * 0.5),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: containerHeight * .30,
//                 width: containerWidth * .83,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   onPressed: () {
//                     print('Row Button 3');
//                   },
//                   child: Text(
//                     'Forgot what this did',
//                     style: TextStyle(fontSize: buttonFontSize * 0.5),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




