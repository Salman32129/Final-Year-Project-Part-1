import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tomato_care/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDa2HL8kmXiGecCGNrCIbVMGDwED4s691k",
        authDomain: "tomato-db-a6bf2.firebaseapp.com",
        projectId: "tomato-db-a6bf2",
        storageBucket: "tomato-db-a6bf2.appspot.com",
        messagingSenderId: "686238013661",
        appId: "1:686238013661:android:ef8e42581f9252cb0d2334",
      ),
    );
    print("Firebase connection is established.");
  } catch (error) {
    print("Error initializing Firebase: $error");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        primaryColor: Colors.green,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1, // Adjust as needed for your image aspect ratio
            child: Image.asset('assets/splash_image.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
