import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tomato_care/AddTreatmentForm.dart';
import 'package:tomato_care/UpdateTreatmentPage.dart';
import 'package:tomato_care/RemoveTreatmentPage.dart';

class ManageTreatmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Treatment'),
      ),
      backgroundColor: Colors.grey[200], // Set background color
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to AddTreatmentForm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTreatmentForm(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add Treatment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Set custom background color
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to UpdateTreatmentPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateTreatmentList(),
                  ),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('Update Treatment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set custom background color
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to RemoveTreatmentPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RemoveTreatmentPage(),
                  ),
                );
              },
              icon: Icon(Icons.delete),
              label: Text('Remove Treatment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set custom background color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateTreatmentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Treatment'),
      ),
      backgroundColor: Colors.grey[200], // Set background color
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

          return ListView.builder(
            itemCount: treatments.length,
            itemBuilder: (context, index) {
              final treatment = treatments[index];
              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    treatment['diseaseName'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Percentage: ${treatment['diseasePercentage']}%',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  trailing: Icon(Icons.edit),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateTreatmentPage(treatment: treatment),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
