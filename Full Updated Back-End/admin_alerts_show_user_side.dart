import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAlertPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Alerts'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AlertDataTable(),
        ),
      ),
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
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final docs = snapshot.data!.docs;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingTextStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            dataTextStyle: TextStyle(fontSize: 14),
            columns: [
              DataColumn(
                label: Text(
                  'Alert Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: docs.map((doc) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        _getAlertIcon(doc['alertType']),
                        SizedBox(width: 5),
                        Text(
                          doc['alertType'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(doc['dateTime'])),
                ],
                onSelectChanged: (_) {
                  _showAlertDescription(context, doc['description']);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _getAlertIcon(String alertType) {
    IconData icon;
    switch (alertType) {
      case 'Weather Alerts':
        icon = Icons.cloud;
        break;
      case 'Disease Alerts':
        icon = Icons.healing;
        break;
      case 'Treatment Alerts':
        icon = Icons.medical_services;
        break;
      default:
        icon = Icons.warning;
        break;
    }
    return Icon(icon,
        color: alertType == 'Weather Alerts'
            ? Colors.blue
            : Colors.red); // Blue color for weather alerts, red for others
  }

  void _showAlertDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alert Description'),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
