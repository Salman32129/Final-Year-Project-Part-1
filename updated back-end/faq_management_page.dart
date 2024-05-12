import 'package:flutter/material.dart';
import 'add_faq_page.dart'; // Import AddFAQPage
import 'edit_faq_page.dart'; // Import EditFAQPage
import 'delete_faq_page.dart'; // Import RemoveFAQPage

class FAQManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage FAQs',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue, // Apply a brand color
        elevation: 0.0, // Remove default shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FAQ Management',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto', // Apply a font family (optional)
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            _buildFAQTile(
              icon: Icon(Icons.add, color: Colors.blue),
              text: 'Add FAQ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFAQPage(),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildFAQTile(
              icon: Icon(Icons.edit, color: Colors.blue),
              text: 'Edit FAQ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditFAQPage(),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildFAQTile(
              icon: Icon(Icons.delete, color: Colors.blue),
              text: 'Remove FAQ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteFAQPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(
      {required Icon icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      // Use InkWell for entire tile clickability
      onTap: onTap,
      child: Container(
        // Use a Container for styling
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          color: Colors.grey.shade200, // Light background color for contrast
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 16.0),
            Expanded(
              // Expand text widget to fill remaining space
              child: Text(
                text,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              color: Colors.blue,
              onPressed:
                  () {}, // Disable icon button functionality since entire tile is clickable
            ),
          ],
        ),
      ),
    );
  }
}
