import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAlertRemovePage extends StatefulWidget {
  @override
  _AdminAlertRemovePageState createState() => _AdminAlertRemovePageState();
}

class _AdminAlertRemovePageState extends State<AdminAlertRemovePage> {
  String? _removeMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remove Alerts',
          style: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AlertDataTable(_showRemoveMessage),
          ),
          if (_removeMessage != null)
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.green,
              child: Text(
                _removeMessage!,
                style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
              ),
            ),
        ],
      ),
    );
  }

  void _showRemoveMessage(String message) {
    setState(() {
      _removeMessage = message;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _removeMessage = null;
      });
    });
  }
}

class AlertDataTable extends StatelessWidget {
  final Function(String) showRemoveMessage;

  AlertDataTable(this.showRemoveMessage);

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
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontFamily: 'Roboto'),
            ),
          );
        }
        final docs = snapshot.data!.docs;
        return DataTable(
          columns: [
            DataColumn(
                label:
                    Text('Alert Type', style: TextStyle(fontFamily: 'Roboto'))),
            DataColumn(
                label:
                    Text('Date Time', style: TextStyle(fontFamily: 'Roboto'))),
            DataColumn(
                label: Text('Action', style: TextStyle(fontFamily: 'Roboto'))),
          ],
          rows: docs.map((doc) {
            return DataRow(
              cells: [
                DataCell(Text(doc['alertType'],
                    style: TextStyle(fontFamily: 'Roboto'))),
                DataCell(Text(doc['dateTime'],
                    style: TextStyle(fontFamily: 'Roboto'))),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showRemoveConfirmation(context, doc);
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

  void _showRemoveConfirmation(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Removal',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to remove this alert?',
                    style: TextStyle(fontFamily: 'Roboto')),
                SizedBox(height: 10),
                Text('Description:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                Text(doc['description'],
                    style: TextStyle(fontFamily: 'Roboto')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontFamily: 'Roboto')),
            ),
            TextButton(
              onPressed: () {
                _removeAlert(context, doc);
              },
              child: Text('Remove',
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _removeAlert(BuildContext context, DocumentSnapshot doc) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_alerts')
          .doc(doc.id)
          .delete();
      var message = 'Alert removed successfully!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      showRemoveMessage(message);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove alert: $error',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(context).pop();
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminAlertRemovePage(),
  ));
}
