import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_alert_update_page.dart'; // Import the AdminAlertUpdatePage
import 'admin_alert_remove_page.dart'; // Import the AdminAlertRemovePage

class AdminManageAlertsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Alerts',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Show dialog box to add alert
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddAlertDialog();
                    },
                  );
                },
                icon: Icon(Icons.add),
                label: Text(
                  'Add Alert',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the AdminAlertUpdatePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminAlertUpdatePage()),
                  );
                },
                icon: Icon(Icons.edit),
                label: Text(
                  'Update Alerts',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the AdminAlertRemovePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminAlertRemovePage()),
                  );
                },
                icon: Icon(Icons.delete),
                label: Text(
                  'Remove Alerts',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Current Alerts:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Expanded(
                child: AlertsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlertsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('admin_alerts').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(fontFamily: 'Roboto'),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No alerts found.',
              style: TextStyle(fontFamily: 'Roboto'),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.notification_important),
              ),
              title: Text(
                '${index + 1}. ${data['alertType']}',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              subtitle: Text(
                data['dateTime'],
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              onTap: () {
                // Show dialog box with full description
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Alert Description',
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                      content: Text(
                        data['description'],
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class AddAlertDialog extends StatefulWidget {
  @override
  _AddAlertDialogState createState() => _AddAlertDialogState();
}

class _AddAlertDialogState extends State<AddAlertDialog> {
  final TextEditingController _alertTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Alert',
        style: TextStyle(fontFamily: 'Roboto'),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _alertTypeController,
              decoration: InputDecoration(
                labelText: 'Alert Type',
                labelStyle: TextStyle(fontFamily: 'Roboto'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter alert type';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(fontFamily: 'Roboto'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Close the dialog box
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Save the alert to the database
            if (_formKey.currentState!.validate()) {
              bool success = await saveAlert(context);
              // Show success message if saved successfully
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Alert saved successfully!',
                      style: TextStyle(fontFamily: 'Roboto'),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Close the dialog box
                Navigator.of(context).pop();
              }
            }
          },
          child: Text(
            'Save',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
        ),
      ],
    );
  }

  Future<bool> saveAlert(BuildContext context) async {
    // Get the current date and time
    DateTime now = DateTime.now();
    String dateTime = now.toString();

    // Get the values from the text fields
    String alertType = _alertTypeController.text;
    String description = _descriptionController.text;

    try {
      // Add the alert to the 'admin_alerts' collection in Firestore
      await FirebaseFirestore.instance.collection('admin_alerts').add({
        'alertType': alertType,
        'description': description,
        'dateTime': dateTime,
      });

      // Alert saved successfully
      return true;
    } catch (e) {
      // Error saving alert
      print('Error saving alert: $e');
      return false;
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _alertTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminManageAlertsPage(),
  ));
}
