import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tomato_care/alert_page.dart';
import 'package:tomato_care/index_page.dart';
import 'package:tomato_care/login_screen.dart';
import 'package:tomato_care/profilePage.dart';
import 'package:tomato_care/report.dart';
import 'package:tomato_care/user_faq_page.dart';

void main() {
  runApp(MaterialApp(
    home: CareCalendarPage(),
  ));
}

class CareCalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Care Calendar',
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
      ),
      drawer: _buildDrawer(context), // Add the drawer here
      body: Center(
        child: EventTable(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventScreen()),
          ).then((value) {
            if (value != null && value is bool && value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Event added successfully!'),
              ));
            }
          });
        },
        child: Icon(Icons.add),
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

class EventTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('care_calendar').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return EventCard(
                title: data['title'],
                description: data['description'],
                startDateTime: data['startDateTime'],
                onTap: () {
                  _showEventDescription(context, data['description']);
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditEventScreen(
                        event: data,
                        eventId: document.id,
                      ),
                    ),
                  ).then((value) {
                    if (value != null && value is bool && value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Event updated successfully!'),
                      ));
                    }
                  });
                },
                onDelete: () {
                  FirebaseFirestore.instance
                      .collection('care_calendar')
                      .doc(document.id)
                      .delete()
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Event deleted successfully!'),
                    ));
                  });
                },
              );
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void _showEventDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Event Description'),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String startDateTime;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  EventCard({
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          startDateTime,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  }
                },
                icon: Icon(Icons.calendar_today),
                label: Text(_selectedDateTime == null
                    ? 'Select Date & Time'
                    : 'Date & Time Selected'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDateTime != null) {
                      FirebaseFirestore.instance
                          .collection('care_calendar')
                          .add({
                        'title': _titleController.text,
                        'description': _descriptionController.text,
                        'startDateTime': _selectedDateTime!.toIso8601String(),
                        'showDescription': false,
                      }).then((value) {
                        Navigator.pop(context, true);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Please fill all fields and select date & time!'),
                      ));
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final String eventId;

  EditEventScreen({required this.event, required this.eventId});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event['title'];
    _descriptionController.text = widget.event['description'];
    _selectedDateTime = DateTime.parse(widget.event['startDateTime']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          _selectedDateTime ?? DateTime.now()),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  }
                },
                icon: Icon(Icons.calendar_today),
                label: Text(_selectedDateTime == null
                    ? 'Select Date & Time'
                    : 'Date & Time Selected'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDateTime != null) {
                      FirebaseFirestore.instance
                          .collection('care_calendar')
                          .doc(widget.eventId)
                          .update({
                        'title': _titleController.text,
                        'description': _descriptionController.text,
                        'startDateTime': _selectedDateTime!.toIso8601String(),
                      }).then((value) {
                        Navigator.pop(context, true);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Please fill all fields and select date & time!'),
                      ));
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
