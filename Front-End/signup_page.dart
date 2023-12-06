import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.jpg',
                height: 100,
                width: 100,
              ),
              SizedBox(height: 20),
              buildTextField(
                controller: usernameController,
                labelText: 'Username',
                prefixIcon: Icons.person,
                textColor: Color.fromARGB(255, 43, 10, 10),
                iconColor: Color.fromARGB(255, 216, 1, 1),
                borderColor: Color.fromARGB(255, 216, 1, 1),
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
                textColor: Color.fromARGB(255, 43, 10, 10),
                iconColor: Color.fromARGB(255, 216, 1, 1),
                borderColor: Color.fromARGB(255, 216, 1, 1),
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: phoneController,
                labelText: 'Phone',
                prefixIcon: Icons.phone,
                textColor: Color.fromARGB(255, 43, 10, 10),
                iconColor: Color.fromARGB(255, 216, 1, 1),
                borderColor: Color.fromARGB(255, 216, 1, 1),
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
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Perform signup logic here
                  // For simplicity, navigate back to the previous screen
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 216, 1, 1), // Use orange as the button color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Comfortaa',
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: iconColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 251, 255, 255), // Use a light teal background color
      ),
    );
  }
}
