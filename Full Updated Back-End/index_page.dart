import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tomato_care/treatment_page.dart';
import 'package:tomato_care/user_faq_page.dart';
import 'profilePage.dart';
import 'login_screen.dart';
import 'report.dart';
import 'alert_page.dart';
import 'care_celandar.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return _buildHomePage(context, snapshot.data!);
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }

  Widget _buildHomePage(BuildContext context, User user) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tomato Care',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 247, 249, 250),
            fontStyle: FontStyle.italic,
            letterSpacing: 1.5,
            wordSpacing: 2.0,
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
            decorationStyle: TextDecorationStyle.dashed,
            fontFamily: 'Comfortaa',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildMainContent(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Diagnose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Care Calendar',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IndexPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlertPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CareCalendarPage()),
            );
          }
        },
      ),
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                String username = snapshot.data!.get('username') ?? 'Guest';
                return _buildDrawer(context, user.uid, username);
              } else {
                return CircularProgressIndicator();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Upload an image of your tomato plant for disease detection.',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Open image picker
                      File? image = await _getImage(ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        _uploadImage(image);
                      }
                    },
                    icon: Icon(Icons.upload),
                    label: Text(
                      'Upload',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Open camera to capture image
                      File? image = await _getImage(ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        _uploadImage(image);
                      }
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text(
                      'Camera',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<File?> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Check if the picked file is an image based on its file extension
      final isImage = ['jpg', 'jpeg', 'png', 'gif']
          .any((ext) => pickedFile.path.toLowerCase().endsWith(ext));

      // Optionally, you can also check the MIME type of the file
      // final isImage = pickedFile.mimeType.startsWith('image');

      if (isImage) {
        return File(pickedFile.path);
      } else {
        // Show a message that only image files are allowed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Only image files are allowed.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
    return null;
  }

  void _uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.18.43:8000/predict')); // Replace YOUR_SERVER_IP with your server IP
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _showResponseDialog(
            responseData, imageFile, FirebaseAuth.instance.currentUser!.email!);
      } else {
        _showErrorDialog('Error', 'Failed to upload image');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to upload image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResponseDialog(
      Map<String, dynamic> responseData, File imageFile, String userEmail) {
    bool isError = responseData.containsKey('error');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Disease Report',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 40), // Adjust spacing
                  ],
                ),
                SizedBox(height: 20.0),
                // Display the uploaded photo
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                SizedBox(height: 20.0),
                // Display the icon based on error status
                Icon(
                  isError ? Icons.close : Icons.check,
                  size: 40.0,
                  color: isError ? Colors.red : Colors.green,
                ),
                SizedBox(height: 10.0),
                // Display error message or analysis result
                Text(
                  isError
                      ? 'Error: ${responseData['error']}'
                      : 'Here is the analysis result:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                // Display analysis result if no error
                if (!isError)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Result:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      _buildResultItem(
                        title: 'Affected:',
                        value: responseData['Affected'] ?? 'Unknown',
                      ),
                      _buildResultItem(
                        title: 'Disease:',
                        value: responseData['Disease'] ?? 'Unknown',
                      ),
                    ],
                  ),
                SizedBox(height: 20.0),
                // Display save and treatment buttons if no error
                if (!isError)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await saveReportToFirestore(
                                userEmail,
                                responseData['Affected'] ?? 'Unknown',
                                responseData['Disease'] ?? 'Unknown');
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Report Saved'),
                                  content: Text('The report has been saved.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch (e) {
                            _showErrorDialog('Error', 'Failed to save report');
                          }
                        },
                        icon: Icon(Icons.save),
                        label: Text('Save'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TreatmentPage(
                                diseaseName: responseData['Disease'] as String?,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.medical_services),
                        label: Text('Treatment'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultItem({required String title, required dynamic value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${value is int ? '$value%' : value}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, String userId, String username) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            "Welcome, $username",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          accountEmail: null,
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              username.isNotEmpty ? username[0] : 'G',
              style: TextStyle(fontSize: 40.0),
            ),
          ),
          decoration: const BoxDecoration(
            color: Colors.red,
            image: DecorationImage(
              image: AssetImage('assets/sideBar-BG.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IndexPage()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userId)),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.chat),
          title: Text('FAQs'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserFAQPage()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () async {
            // Sign out user from Firebase
            await FirebaseAuth.instance.signOut();

            // Navigate to login screen and clear previous routes
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) =>
                  false, // Remove all routes from the stack
            );
          },
        ),
      ],
    );
  }

  Future<void> saveReportToFirestore(
      String userEmail, dynamic affected, dynamic disease) async {
    try {
      await FirebaseFirestore.instance.collection('user_reports').add({
        'user_email': userEmail,
        'date': DateTime.now(),
        'affected': affected,
        'disease': disease,
      });
    } catch (e) {
      throw e;
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: IndexPage(),
  ));
}
