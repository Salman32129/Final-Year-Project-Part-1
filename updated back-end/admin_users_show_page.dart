import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersShowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Users',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          return Center(
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16.0,
                    columns: [
                      DataColumn(
                        label: Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 8.0),
                            Text('Username',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      DataColumn(
                        label: Row(
                          children: [
                            Icon(Icons.email, color: Colors.blue),
                            SizedBox(width: 8.0),
                            Text('Email',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      DataColumn(
                        label: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.blue),
                            SizedBox(width: 8.0),
                            Text('Phone',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                    dataRowHeight: 72.0,
                    rows: documents.map((document) {
                      final data = document.data() as Map<String, dynamic>;
                      return DataRow(
                        cells: [
                          DataCell(Text(data['username'] ?? 'No Username')),
                          DataCell(Text(data['email'] ?? 'No Email')),
                          DataCell(Text(data['phone'] ?? 'No Phone')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
