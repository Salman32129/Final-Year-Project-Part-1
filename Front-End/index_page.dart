import 'package:flutter/material.dart';
import 'login_screen.dart';import 'report.dart'; // Import the report.dart file

class IndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tomato Care',
          style: TextStyle(
                     fontSize: 20, // Adjust the font size as needed
                     fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 247, 249, 250),        // Set the text color
                    fontStyle: FontStyle.italic, // Set the font style
                    letterSpacing: 1.5,         // Set the letter spacing
                    wordSpacing: 2.0,           // Set the word spacing
                    decoration: TextDecoration.underline, // Set text decoration
                    decorationColor: Colors.red, // Set decoration color
                    decorationStyle: TextDecorationStyle.dashed, // Set decoration style
                    fontFamily: 'Comfortaa'
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red, // Change the app bar background color to red
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome to Your Plant\'s Health Hub',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 24, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Change the text color
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Upload an image of your tomato plant for disease detection.',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 18, // Adjust the font size as needed
                    color: Colors.white, // Change the text color
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add your logic for selecting an image here
                  },
                  child: Text('Select Image',
                  
                  style: TextStyle(
                     fontFamily: 'Comfortaa',
                  ),
                  ),
                  
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red, // Change the bottom navigation bar color to red
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            
            icon: Icon(Icons.camera_alt),
            label: 'Diagnose',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}
