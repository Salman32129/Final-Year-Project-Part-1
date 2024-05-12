import 'package:flutter/material.dart';

import 'login_screen.dart';

class PasswordResetPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Comfortaa',
              color: Color.fromARGB(255, 240, 240, 240), // Set the text color
            ),
          ),
        ),
        backgroundColor: Colors.red, // Set your desired app bar color
        iconTheme: IconThemeData(color: Colors.black), // Set the icon color
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.jpg', // Provide your own reset password image
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Enter your email to reset the password',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email), // Add an email icon
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Call the resetPassword method from LoginScreen
                  LoginScreen.resetPassword(context, emailController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 243, 33, 33), // Set your desired button color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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
