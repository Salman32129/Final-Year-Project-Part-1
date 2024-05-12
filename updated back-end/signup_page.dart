import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_field_validator/form_field_validator.dart'
    as form_validator;

import 'login_screen.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isSignUpSuccessful = false;
  String? emailError;
  String? phoneError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Color.fromARGB(255, 240, 240, 240),
              fontFamily: 'Comfortaa',
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 216, 1, 1),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: isSignUpSuccessful
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildSuccessMessage(context),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        child: Text(
                          'Go to Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildTextField(
                          controller: usernameController,
                          labelText: 'Username',
                          prefixIcon: Icons.person,
                          textColor: Color.fromARGB(255, 43, 10, 10),
                          iconColor: Color.fromARGB(255, 216, 1, 1),
                          borderColor: Color.fromARGB(255, 216, 1, 1),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '*Username is required';
                            }
                            if (value.trim().isEmpty) {
                              return 'Username cannot consist of only spaces';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        buildTextField(
                          controller: emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          textColor: Color.fromARGB(255, 43, 10, 10),
                          iconColor: Color.fromARGB(255, 216, 1, 1),
                          borderColor: Color.fromARGB(255, 216, 1, 1),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return '*Email is required';
                            }
                            if (emailError != null) {
                              return emailError;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        buildTextField(
                          controller: phoneController,
                          labelText: 'Phone',
                          prefixIcon: Icons.phone,
                          textColor: Color.fromARGB(255, 43, 10, 10),
                          iconColor: Color.fromARGB(255, 216, 1, 1),
                          borderColor: Color.fromARGB(255, 216, 1, 1),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return '*Phone is required';
                            }
                            if (phoneError != null) {
                              return phoneError;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        buildTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          textColor: Color.fromARGB(255, 43, 10, 10),
                          iconColor: Color.fromARGB(255, 216, 1, 1),
                          borderColor: Color.fromARGB(255, 216, 1, 1),
                          validator: form_validator.MultiValidator([
                            form_validator.RequiredValidator(
                                errorText: "*Password Required"),
                            form_validator.MinLengthValidator(6,
                                errorText:
                                    "Password should be at least 6 characters"),
                            form_validator.MaxLengthValidator(15,
                                errorText:
                                    "Password should not be greater than 15 characters"),
                          ]),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            signUp(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 216, 1, 1),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Comfortaa',
                              color: const Color.fromARGB(255, 250, 248, 248),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.green,
          ),
          SizedBox(height: 10),
          Text(
            'User registered successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    required Color textColor,
    required Color iconColor,
    required Color borderColor,
    form_validator.FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: textColor),
        validator: validator,
        onChanged: (value) {
          setState(() {
            if (controller == phoneController) {
              if (!RegExp(r'^[0-9]+$').hasMatch(value) ||
                  value.length < 11 ||
                  value.length > 15) {
                phoneError =
                    "Phone number should be between 11 and 15 digits and must contain only digits.";
              } else {
                phoneError = null;
              }
            } else if (controller == emailController) {
              if (!form_validator.EmailValidator(errorText: '')
                  .isValid(value)) {
                emailError = 'Enter valid email id';
              } else {
                emailError = null;
              }
            }
          });
        },
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon, color: iconColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 251, 255, 255),
          errorText: validator != null
              ? null
              : (controller == phoneController ? phoneError : emailError),
        ),
      ),
    );
  }

  void signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String username = usernameController.text.trim();
      String email = emailController.text.trim();
      String phone = phoneController.text.trim();
      String password = passwordController.text.trim();

      try {
        // Reset emailError before querying
        setState(() {
          emailError = null;
        });

        // Check if user already exists with provided email
        await checkUserExists(email);

        // If user already exists, return without signing up
        if (emailError != null) return;

        // Create user in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String userId = userCredential.user!.uid;

        // Store user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'username': username,
          'email': email,
          'phone': phone,
        });

        // Set signup success state
        setState(() {
          isSignUpSuccessful = true;
        });

        // Reset success state after 6 seconds
        Future.delayed(Duration(seconds: 6), () {
          setState(() {
            isSignUpSuccessful = false;
          });
        });

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        print('Error during signup: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(
                  "An error occurred during signup. Please try again. Error: $e"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> checkUserExists(String email) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get(GetOptions(
              source: Source.server)); // Fetch latest data from server

      if (query.docs.isNotEmpty) {
        setState(() {
          emailError = "User already exists with this email.";
        });
      } else {
        setState(() {
          emailError = null;
        });
      }
    } catch (e) {
      print('Error checking user: $e');
      setState(() {
        emailError = "Error checking user. Please try again.";
      });
    }
  }
}
