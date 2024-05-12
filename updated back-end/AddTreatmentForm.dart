import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class AddTreatmentForm extends StatefulWidget {
  @override
  _AddTreatmentFormState createState() => _AddTreatmentFormState();
}

class _AddTreatmentFormState extends State<AddTreatmentForm> {
  final _formKey = GlobalKey<FormState>();
  String diseaseName = '';
  double diseasePercentage = 0;
  String addTreatment = '';

  // Function to save treatment data to Firestore
  Future<void> _saveTreatmentData() async {
    try {
      await FirebaseFirestore.instance.collection('manage_treatment').add({
        'diseaseName': diseaseName,
        'diseasePercentage': diseasePercentage,
        'addTreatment': addTreatment,
      });
      // Data saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Treatment added successfully')),
      );
    } catch (e) {
      // Error occurred while saving data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add treatment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Treatment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Disease Name',
                  prefixIcon: Icon(Icons.healing),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter disease name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    diseaseName = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Disease Percentage',
                  prefixIcon: Icon(Icons.pie_chart),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0 ||
                      double.parse(value) > 100) {
                    return 'Please enter a valid percentage between 0 and 100';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    diseasePercentage = double.parse(value);
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Add Treatment',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter treatment';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    addTreatment = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save the data to Firestore
                    _saveTreatmentData();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
