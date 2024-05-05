import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                // Navigate to update alerts page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminAlertUpdatePage(),
                  ),
                );
              },
              child: Text('Update Alerts'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality for removing alerts
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

class AdminAlertUpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Alerts'),
      ),
      body: AlertDataTable(),
    );
  }
}

class AlertDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('admin_alerts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final docs = snapshot.data!.docs;
        return DataTable(
          columns: [
            DataColumn(label: Text('Alert Type')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Date Time')),
            DataColumn(label: Text('Action')),
          ],
          rows: docs.map((doc) {
            return DataRow(
              cells: [
                DataCell(Text(doc['alertType'])),
                DataCell(Text(doc['description'])),
                DataCell(Text(doc['dateTime'])),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit page and pass document ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAlertPage(docId: doc.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class EditAlertPage extends StatefulWidget {
  final String docId;

  EditAlertPage({required this.docId});

  @override
  _EditAlertPageState createState() => _EditAlertPageState();
}

class _EditAlertPageState extends State<EditAlertPage> {
  final TextEditingController _alertTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the existing alert data when the widget is initialized
    fetchAlertData();
  }

  void fetchAlertData() async {
    try {
      // Retrieve the existing alert data from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin_alerts')
          .doc(widget.docId)
          .get();

      // Populate the text controllers with the existing data
      _alertTypeController.text = snapshot['alertType'];
      _descriptionController.text = snapshot['description'];
    } catch (e) {
      print('Error fetching alert data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Alert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _alertTypeController,
              decoration: InputDecoration(labelText: 'Alert Type'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Save the updated alert
                bool success = await updateAlert(widget.docId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alert updated successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context); // Go back to previous page
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> updateAlert(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_alerts')
          .doc(docId)
          .update({
        'alertType': _alertTypeController.text,
        'description': _descriptionController.text,
        'dateTime': DateTime.now().toString(),
      });
      return true;
    } catch (e) {
      print('Error updating alert: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _alertTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
