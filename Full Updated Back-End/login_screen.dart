import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tomato_care/admin_dashboard.dart'; // Import admin dashboard page
import 'package:tomato_care/index_page.dart'; // Import user dashboard page
import 'package:tomato_care/password_reset_page.dart';
import 'package:tomato_care/signup_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  static void resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Password reset email sent successfully. Please check your inbox.'),
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email: ';
      switch (e.code) {
        case 'invalid-email':
          errorMessage += 'The email address is badly formatted.';
          break;
        case 'user-not-found':
          errorMessage += 'No user found with this email.';
          break;
        default:
          errorMessage += 'An unexpected error occurred.';
          break;
      }
      // Show error message in SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String emailError = '';
  String passwordError = '';

  Future<void> signIn(BuildContext context) async {
    setState(() {
      emailError = '';
      passwordError = '';
    });

    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Fetch user's role from Firestore
      String? userRole = await _getUserRole(userCredential.user?.uid);

      // Navigate based on user's role
      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IndexPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          emailError = 'Email not found';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          passwordError = 'Incorrect password';
        });
      } else {
        setState(() {
          emailError = 'Email or Password incorrect. Please try again.';
        });
      }
    }
  }

  Future<String?> _getUserRole(String? userId) async {
    if (userId == null) return null;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if the user exists and has a role field
      if (userSnapshot.exists && userSnapshot.data() is Map<String, dynamic>) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('role')) {
          return userData['role'];
        }
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text('Login'), // Add a title to the app bar
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.jpg',
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: Colors.red),
                    errorText: emailError.isNotEmpty ? emailError : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Colors.red),
                    errorText: passwordError.isNotEmpty ? passwordError : null,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    signIn(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 56, 56),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 253, 254, 255),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      wordSpacing: 2.0,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.red,
                      decorationStyle: TextDecorationStyle.dashed,
                      fontFamily: 'Comfortaa',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Add forgot password functionality or navigate to the forgot password screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PasswordResetPage()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style:
                        TextStyle(color: Colors.grey, fontFamily: 'Comfortaa'),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Sign up',
                    style:
                        TextStyle(color: Colors.blue, fontFamily: 'Comfortaa'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
