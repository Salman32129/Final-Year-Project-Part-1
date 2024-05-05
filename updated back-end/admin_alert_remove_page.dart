import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAlertRemovePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Alerts'),
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
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Remove the document from Firestore
                      FirebaseFirestore.instance
                          .collection('admin_alerts')
                          .doc(doc.id)
                          .delete()
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Alert removed successfully!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to remove alert: $error'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
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
