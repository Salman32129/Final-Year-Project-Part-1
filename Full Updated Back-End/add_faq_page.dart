import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add FAQ'),
      ),
      body: FAQList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFAQDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddFAQDialog(BuildContext context) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: questionController,
              decoration: InputDecoration(labelText: 'Question'),
            ),
            TextFormField(
              controller: answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveFAQ(questionController.text, answerController.text, context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveFAQ(String question, String answer, BuildContext context) async {
    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('FAQs').add({
        'question': question,
        'answer': answer,
      });
      print('FAQ added successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAQ added successfully')),
      );
      Navigator.pop(context); // Close the dialog
    } catch (e) {
      print('Error adding FAQ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding FAQ')),
      );
    }
  }
}

class FAQList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final question = doc['question'];
            final answer = doc['answer'];
            return FAQListItem(question: question, answer: answer);
          },
        );
      },
    );
  }
}

class FAQListItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQListItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(question),
          subtitle: Text(answer),
        ),
        Divider(),
      ],
    );
  }
}
