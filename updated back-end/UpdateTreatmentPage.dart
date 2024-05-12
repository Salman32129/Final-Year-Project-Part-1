import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateTreatmentPage extends StatelessWidget {
  final DocumentSnapshot treatment;

  UpdateTreatmentPage({required this.treatment});

  @override
  Widget build(BuildContext context) {
    TextEditingController diseaseController =
        TextEditingController(text: treatment['diseaseName']);
    TextEditingController percentageController =
        TextEditingController(text: treatment['diseasePercentage'].toString());
    TextEditingController treatmentController =
        TextEditingController(text: treatment['addTreatment']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Treatment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: diseaseController,
              decoration: InputDecoration(
                labelText: 'Disease Name',
                prefixIcon: Icon(Icons.healing),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: percentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Disease Percentage',
                prefixIcon: Icon(Icons.pie_chart),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: treatmentController,
              decoration: InputDecoration(
                labelText: 'Treatment',
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int? percentage = int.tryParse(percentageController.text);
                if (percentage != null) {
                  _updateTreatment(
                    treatment.id,
                    diseaseController.text,
                    percentage,
                    treatmentController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Treatment updated successfully')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid percentage value')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTreatment(
      String docId, String diseaseName, int percentage, String treatment) {
    FirebaseFirestore.instance
        .collection('manage_treatment')
        .doc(docId)
        .update({
      'diseaseName': diseaseName,
      'diseasePercentage': percentage,
      'addTreatment': treatment,
    });
  }
}
