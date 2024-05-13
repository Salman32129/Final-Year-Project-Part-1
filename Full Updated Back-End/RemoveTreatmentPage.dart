import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveTreatmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Treatment'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('manage_treatment')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final treatments = snapshot.data?.docs ?? [];

          return Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 20.0, // Adjust spacing between columns
                columns: [
                  DataColumn(
                      label: Text('Disease Name',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Percentage',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Action',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: treatments.map((treatment) {
                  return DataRow(cells: [
                    DataCell(Text(treatment['diseaseName'],
                        style: TextStyle(fontSize: 16))),
                    DataCell(Text('${treatment['diseasePercentage']}%',
                        style: TextStyle(fontSize: 16))),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _removeTreatment(treatment.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Treatment removed')),
                        );
                        Navigator.pop(context);
                      },
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _removeTreatment(String docId) {
    FirebaseFirestore.instance
        .collection('manage_treatment')
        .doc(docId)
        .delete();
  }
}
