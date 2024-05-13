import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentPage extends StatefulWidget {
  final String? diseaseName;

  TreatmentPage({Key? key, this.diseaseName}) : super(key: key);

  @override
  _TreatmentPageState createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Treatments',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: _buildTreatmentList(),
    );
  }

  Widget _buildTreatmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('manage_treatment').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final treatments = snapshot.data?.docs ?? [];

        final filteredTreatments = treatments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final percentage = data['diseasePercentage'] as int?;
          final disease = data['diseaseName'] as String?;
          if (percentage != null && disease != null) {
            if (disease == widget.diseaseName) {
              if ((percentage >= 0 && percentage <= 30) ||
                  (percentage > 30 && percentage <= 60) ||
                  (percentage > 60 && percentage <= 100)) {
                return true;
              }
            }
          }
          return false;
        }).toList();

        if (filteredTreatments.isEmpty) {
          return Center(
            child: Text(
              'No treatments found for the selected disease and range.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredTreatments.length,
          itemBuilder: (context, index) {
            final data =
                filteredTreatments[index].data() as Map<String, dynamic>;
            return _buildTreatmentItem(
              data['addTreatment'] as String?,
              data['diseaseName'] as String?,
              data['diseasePercentage'] as int?,
            );
          },
        );
      },
    );
  }

  Widget _buildTreatmentItem(
      String? addTreatment, String? diseaseName, int? diseasePercentage) {
    String percentageRange = _getPercentageRange(diseasePercentage);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(Icons.local_hospital, color: Colors.redAccent),
          title: Text(
            diseaseName ?? 'Unknown Disease',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontFamily: 'Montserrat',
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Affected Percentage: $percentageRange',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.assignment, color: Colors.redAccent),
                ],
              ),
              SizedBox(height: 8),
              Text(
                addTreatment ?? 'No Treatment Available',
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPercentageRange(int? percentage) {
    if (percentage == null) {
      return 'Unknown';
    } else if (percentage >= 0 && percentage <= 30) {
      return '0 to 30%';
    } else if (percentage > 30 && percentage <= 60) {
      return '31 to 60%';
    } else {
      return '61 to 100%';
    }
  }
}
