import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_alert_update_page.dart'; // Import the AdminAlertUpdatePage
import 'admin_alert_remove_page.dart'; // Import the AdminAlertRemovePage

class AdminManageAlertsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Alerts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Show dialog box to add alert
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddAlertDialog();
                  },
                );
              },
              child: Text('Add Alert'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the AdminAlertUpdatePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminAlertUpdatePage()),
                );
              },
              child: Text('Update Alerts'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the AdminAlertRemovePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminAlertRemovePage()),
                );
              },
              child: Text('Remove Alerts'),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Alert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _alertTypeController,
            decoration: InputDecoration(labelText: 'Alert Type'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Close the dialog box
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Save the alert to the database
            bool success = await saveAlert(context);
            // Show success message if saved successfully
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert saved successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
              // Close the dialog box
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
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
