import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tomato_care/index_page.dart';
import 'package:tomato_care/login_screen.dart';
import 'package:tomato_care/profilePage.dart';

class UserFAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 247, 249, 250),
            fontStyle: FontStyle.italic,
            letterSpacing: 1.5,
            wordSpacing: 2.0,
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
            decorationStyle: TextDecorationStyle.dashed,
            fontFamily: 'Comfortaa',
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('FAQs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final docs = snapshot.data!.docs;
          return FAQList(docs: docs);
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
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Text("Error fetching user data");
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          var username = userData?['username'] ?? 'Guest';

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  "Welcome, $username",
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
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(user.uid)),
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
          );
        },
      ),
    );
  }
}

class FAQList extends StatefulWidget {
  final List<QueryDocumentSnapshot> docs;

  const FAQList({
    required this.docs,
    Key? key,
  }) : super(key: key);

  @override
  _FAQListState createState() => _FAQListState();
}

class _FAQListState extends State<FAQList> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.docs.length,
      itemBuilder: (context, index) {
        final doc = widget.docs[index];
        final question = doc['question'];
        final answer = doc['answer'];
        return FAQTile(
          question: question,
          answer: answer,
          isExpanded: _expandedIndex == index,
          onTap: () {
            setState(() {
              _expandedIndex = _expandedIndex == index ? null : index;
            });
          },
        );
      },
    );
  }
}

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQTile({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.blue,
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
