import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUpdateProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String username = '';
    String phone = '';

    void updateProfile(String username, String phone) async {
      if (username.isEmpty || phone.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('All fields are required')));
        return;
      }

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          String adminUserId = querySnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(adminUserId)
              .update({
            'username': username,
            'phone': phone,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Information updated successfully')));
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          });
        } else {
          print('No admin user found');
        }
      } catch (e) {
        print('Error updating profile: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                errorText: username.isEmpty ? 'Username is required' : null,
              ),
              onChanged: (value) {
                username = value;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
                errorText: phone.isEmpty ? 'Phone is required' : null,
              ),
              onChanged: (value) {
                phone = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                updateProfile(username, phone);
              },
              icon: Icon(Icons.update),
              label: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
