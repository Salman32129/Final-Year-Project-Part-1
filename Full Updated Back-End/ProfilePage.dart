import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tomato_care/user_faq_page.dart';
import 'login_screen.dart';
import 'index_page.dart'; // Import the IndexPage and other necessary files

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage(this.userId);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fetchUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    _nameController.text = userData['username'];
    _phoneController.text = userData['phone'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Use the custom app bar
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                String username = snapshot.data!.get('username') ?? 'Guest';
                return _buildDrawer(context, widget.userId, username);
              } else {
                return CircularProgressIndicator();
              }
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildProfileCard(context),
              SizedBox(height: 20),
              _buildProfileDetails(context),
              SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue,
            Colors.lightBlueAccent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.person,
              color: Colors.white,
              size: 60,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      if (snapshot.hasData) {
                        String username =
                            snapshot.data!.get('username') ?? 'Guest';
                        return Text(
                          username,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            String username = snapshot.data!.get('username') ?? 'Unknown';
            String email = snapshot.data!.get('email') ?? 'Unknown';
            String phone = snapshot.data!.get('phone') ?? 'Unknown';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Username', username),
                SizedBox(height: 10),
                _buildDetailRow('Email', email),
                SizedBox(height: 10),
                _buildDetailRow('Phone', phone),
              ],
            );
          } else {
            return Text('Error fetching user data');
          }
        }
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showUpdateProfileDialog(context),
          icon: Icon(Icons.edit),
          label: Text('Update Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showDeleteConfirmationDialog(context),
          icon: Icon(Icons.delete),
          label: Text('Delete Account'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showUpdateProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Update Profile",
            style: TextStyle(
              fontFamily: 'Montserrat',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateProfile();
                Navigator.of(context).pop();
              },
              child: Text(
                "Update",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateProfile() {
    String newName = _nameController.text.trim(); // Trim to remove extra spaces
    String newPhone =
        _phoneController.text.trim(); // Trim to remove extra spaces

    // Check if fields are empty
    if (newName.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and Phone fields cannot be empty')),
      );
      return; // Stop further execution
    }

    // Check if phone number is between 11 to 15 digits
    if (newPhone.length < 11 || newPhone.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number must be between 11 to 15 digits')),
      );
      return; // Stop further execution
    }

    FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'username': newName,
      'phone': newPhone,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }).catchError((error) {
      print("Error updating profile: $error");
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Account",
            style: TextStyle(
              fontFamily: 'Montserrat',
            ),
          ),
          content: Text(
            "Are you sure you want to delete your account?",
            style: TextStyle(
              fontFamily: 'Montserrat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(context);
              },
              child: Text(
                "OK",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user != null) {
      // Delete the user's document from Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete()
          .then((_) {
        // Delete the user's authentication credentials
        user.delete().then((_) {
          // Navigate to the login screen after successful deletion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }).catchError((error) {
          print("Error deleting user account: $error");
        });
      }).catchError((error) {
        print("Error deleting user document: $error");
      });
    } else {
      print("User not logged in.");
    }
  }

  Widget _buildDrawer(BuildContext context, String userId, String username) {
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
          accountEmail: null,
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              username.isNotEmpty ? username[0] : 'G',
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
            Navigator.push(
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
              MaterialPageRoute(builder: (context) => ProfilePage(userId)),
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
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Profile',
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
      elevation: 0.0,
      centerTitle: true,
    );
  }
}
