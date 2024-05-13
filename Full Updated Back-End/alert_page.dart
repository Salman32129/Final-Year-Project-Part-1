import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tomato_care/care_celandar.dart';
import 'package:tomato_care/index_page.dart';
import 'package:tomato_care/login_screen.dart';
import 'package:tomato_care/profilePage.dart';
import 'package:tomato_care/report.dart';
import 'package:tomato_care/user_faq_page.dart';
import 'dart:convert';
import 'admin_alerts_show_user_side.dart'; // Import the admin_alerts_show_user_side.dart file

void main() {
  runApp(MaterialApp(
    home: AlertPage(),
    theme: ThemeData(
      primaryColor: Colors.blue,
      hintColor: Colors.orange,
      fontFamily: 'Roboto',
    ),
  ));
}

class AlertPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather & News',
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
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 16),
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminAlertPage()),
                        );
                      },
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context), // Add the drawer here
      body: WeatherPage(
        defaultLocation: 'Islamabad',
        apiKey: '54d1080248b0242bdb068ae2eb6b2c19',
        newsApiKey: 'b1fe89091e6b447287e170b5341ba3ef',
      ),
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
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not logged in, handle the case appropriately
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Login'),
              onTap: () {
                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      );
    }

    // If user is logged in, build the drawer with user details
    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Text("Error fetching user data");
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          var username = userData?['username'] ?? 'Guest';

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
                accountEmail: Text(
                  user.email ?? '',
                  style: TextStyle(color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user.displayName != null ? user.displayName![0] : 'G',
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
                  Navigator.pushReplacement(
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
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(user.uid)),
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
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  final String apiKey;
  final String newsApiKey;
  final String defaultLocation;

  WeatherPage({
    required this.apiKey,
    required this.newsApiKey,
    required this.defaultLocation,
  });

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Future<Map<String, dynamic>> _weatherData;
  late Future<Map<String, dynamic>> _newsData;
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndNews(widget.defaultLocation);
  }

  Future<Map<String, dynamic>> fetchWeather(String city, String apiKey) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Weather data: $jsonData');
      return jsonData;
    } else {
      print('Failed to load weather data: ${response.statusCode}');
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchNews(String city, String apiKey) async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=tomato%20disease&q=$city&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('News data: $jsonData');
      return jsonData;
    } else {
      print('Failed to load news data: ${response.statusCode}');
      throw Exception('Failed to load news data');
    }
  }

  void _fetchWeatherAndNews(String location) {
    setState(() {
      _weatherData = fetchWeather(location, widget.apiKey);
      _newsData = fetchNews(location, widget.newsApiKey);
    });
  }

  void _changeLocation() {
    _fetchWeatherAndNews(_locationController.text);
    _locationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Enter location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _changeLocation,
                    child: Text('Change Location'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([_weatherData, _newsData]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final List<dynamic>? data = snapshot.data;
                      if (data != null && data.length == 2) {
                        final weatherData = data[0];
                        final newsData = data[1];

                        if (weatherData.containsKey('main') &&
                            weatherData['main'].containsKey('temp') &&
                            weatherData.containsKey('name') &&
                            weatherData['name'] != null &&
                            weatherData['weather'] != null &&
                            weatherData['weather'].isNotEmpty &&
                            weatherData['weather'][0].containsKey('main')) {
                          final temperature =
                              (weatherData['main']['temp'] - 273.15)
                                  .toStringAsFixed(1);
                          final cityName = weatherData['name'];
                          final description = weatherData['weather'][0]['main'];

                          final articles =
                              newsData['articles'] as List<dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'City: $cityName',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Temperature: $temperature°C',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Weather: $description',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: articles.length,
                                  itemBuilder: (context, index) {
                                    final article = articles[index];
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 0),
                                      child: ListTile(
                                        title: Text(
                                          article['title'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(article['description'] ??
                                            'No description available'),
                                        onTap: () {
                                          // Open the full article in a browser or WebView
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                              child: Text('Weather data is incomplete.'));
                        }
                      } else {
                        return Center(
                            child:
                                Text('Data is null or has incorrect length.'));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
