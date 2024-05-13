import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersShowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Users',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
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

          return Container(
            width: double.infinity,
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data =
                        documents[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text(
                        data['username'] ?? 'No Username',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        data['email'] ?? 'No Email',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 4.0,
                              backgroundColor: Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Details',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Row(
                                      children: [
                                        Icon(Icons.person, color: Colors.blue),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Username: ${data['username']}',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.email, color: Colors.blue),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Email: ${data['email']}',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, color: Colors.blue),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Phone: ${data['phone'] ?? 'No Phone'}',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 18.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
