import 'package:flutter/material.dart';
import 'package:tomato_care/admin_manage_alerts.dart';
import 'package:tomato_care/admin_update_profile.dart';
import 'admin_users_show_page.dart';
import 'faq_management_page.dart'; // Import FAQManagementPage
import 'login_screen.dart'; // Import the login screen
import 'ManageTreatmentPage.dart'; // Import ManageTreatmentPage
import 'admin_manage_alerts.dart'; // Import AdminManageAlertsPage

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with WidgetsBindingObserver {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    // Check authentication status when the widget is initialized
    checkAuthenticationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // Check authentication status
  void checkAuthenticationStatus() {
    // For demonstration, assume authentication is successful
    isAuthenticated = true;
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // If the app is paused (minimized), log out the user
      logout();
    }
  }

  // Method to handle logout
  void logout() {
    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    // You may also want to clear any user session or tokens here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Image.asset(
            'assets/logo.jpg',
            height: 60,
            width: 60,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  DashboardItem(
                    icon: Icons.people,
                    title: 'Users',
                    color: Colors.blue,
                    onTap: isAuthenticated
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminUsersShowPage(),
                              ),
                            );
                          }
                        : null,
                  ),
                  DashboardItem(
                    icon: Icons.person,
                    title: 'Update Profile',
                    color: Colors.green,
                    onTap: isAuthenticated
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminUpdateProfile(),
                              ),
                            );
                          }
                        : null,
                  ),
                  DashboardItem(
                    icon: Icons.notifications,
                    title: 'Manage Treatment',
                    color: Colors.orange,
                    onTap: isAuthenticated
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageTreatmentPage(),
                              ),
                            );
                          }
                        : null,
                  ),
                  DashboardItem(
                    icon: Icons.question_answer,
                    title: 'Manage FAQs',
                    color: Colors.purple,
                    onTap: isAuthenticated
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FAQManagementPage(),
                              ),
                            );
                          }
                        : null,
                  ),
                  DashboardItem(
                    icon: Icons.notifications_active,
                    title: 'Manage Alerts',
                    color: Colors.red,
                    onTap: isAuthenticated
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminManageAlertsPage(),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Material(
          // Wrap ElevatedButton in Material to apply InkWell effects
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.red, // Set splashColor for "run" color effect
            borderRadius: BorderRadius.circular(8),
            onTap: isAuthenticated ? logout : null,
            child: Ink(
              height: 48,
              decoration: BoxDecoration(
                color: isAuthenticated
                    ? const Color.fromARGB(255, 243, 33, 33)
                    : Colors
                        .grey, // Change button color based on authentication status
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const DashboardItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: onTap != null
              ? color.withOpacity(0.8)
              : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
