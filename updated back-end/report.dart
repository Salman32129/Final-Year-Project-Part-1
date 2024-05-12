import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tomato_care/care_celandar.dart';
import 'package:tomato_care/index_page.dart';
import 'package:tomato_care/login_screen.dart';
import 'package:tomato_care/profilePage.dart';
import 'package:tomato_care/user_faq_page.dart';

import 'treatment_page.dart'; // Import your TreatmentPage here
import 'alert_page.dart'; // Import your AlertPage here
import 'care_calendar_page.dart'; // Import your CareCalendarPage here
import 'index.dart'; // Import your index page here

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: _buildReportTable(context),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Diagnose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Care Calendar',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IndexPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlertPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CareCalendarPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not logged in, handle the case appropriately
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Login'),
              onTap: () {
                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      );
    }

    // If user is logged in, build the drawer with user details
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              "Welcome, ${user.displayName}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              user.email ?? '',
              style: TextStyle(color: Colors.white),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.displayName != null ? user.displayName![0] : 'G',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: AssetImage('assets/sideBar-BG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IndexPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(user.uid)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('FAQs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserFAQPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not logged in, show a message or handle the case appropriately
      return Center(child: Text('User not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_reports')
          .where('user_email', isEqualTo: user.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No reports found'));
        }

        final reports = snapshot.data!.docs;

        return DataTable(
          columns: [
            DataColumn(
              label: Text(
                'Disease',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: reports.map((report) {
            final reportData = report.data() as Map<String, dynamic>;
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Icon(Icons.local_florist, size: 20),
                      SizedBox(width: 5),
                      Text(reportData['disease'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    _formatDateTime(reportData['date']),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
              onSelectChanged: (isSelected) {
                if (isSelected != null && isSelected) {
                  _showReportDetails(context, reportData, report.id);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showReportDetails(
      BuildContext context, Map<String, dynamic> report, String reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Report Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportDetailRow(
                  Icons.email, 'User Email', report['user_email']),
              _buildReportDetailRow(Icons.calendar_today, 'Date',
                  _formatDateTime(report['date'])),
              _buildReportDetailRow(
                  Icons.local_florist, 'Disease', report['disease']),
              _buildReportDetailRow(Icons.person_outline, 'Affected',
                  report['affected'].toString()),
              // Add more fields as needed
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                _handleTreatment(context, reportId, report['disease']);
              },
              icon: Icon(Icons.local_hospital),
              label: Text('Treatment'),
              style: ElevatedButton.styleFrom(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(''),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeReport(context, reportId),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute}';
  }

  void _removeReport(BuildContext context, String reportId) {
    FirebaseFirestore.instance
        .collection('user_reports')
        .doc(reportId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report removed successfully'),
        ),
      );
      // Close the dialog box after removing the report
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove report: $error'),
        ),
      );
    });
  }

  void _handleTreatment(
      BuildContext context, String reportId, String diseaseName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentPage(diseaseName: diseaseName),
      ),
    );
  }
}
