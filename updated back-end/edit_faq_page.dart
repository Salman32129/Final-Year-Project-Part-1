import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFAQPage extends StatefulWidget {
  @override
  _EditFAQPageState createState() => _EditFAQPageState();
}

class _EditFAQPageState extends State<EditFAQPage> {
  late List<FAQ> faqs;

  @override
  void initState() {
    super.initState();
    faqs = [];
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('FAQs').get();

      final List<FAQ> fetchedFAQs =
          snapshot.docs.map((doc) => FAQ.fromMap(doc.id, doc.data())).toList();

      setState(() {
        faqs = fetchedFAQs;
      });
    } catch (e) {
      print('Error fetching FAQs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit FAQs'),
      ),
      body: DataTable(
        columns: [
          DataColumn(label: Text('Question')),
          DataColumn(label: Text('Answer')),
          DataColumn(label: Text('Action')),
        ],
        rows: faqs
            .map(
              (faq) => DataRow(cells: [
                DataCell(Text(faq.question)),
                DataCell(Text(faq.answer)),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editFAQ(context, faq);
                    },
                  ),
                ),
              ]),
            )
            .toList(),
      ),
    );
  }

  Future<void> _editFAQ(BuildContext context, FAQ faq) async {
    final TextEditingController questionController =
        TextEditingController(text: faq.question);
    final TextEditingController answerController =
        TextEditingController(text: faq.answer);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit FAQ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateFAQ(faq.id, questionController.text,
                    answerController.text, context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFAQ(String faqId, String question, String answer,
      BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('FAQs').doc(faqId).update({
        'question': question,
        'answer': answer,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAQ updated successfully')),
      );
      _fetchFAQs(); // Refresh the list of FAQs after update
    } catch (e) {
      print('Error updating FAQ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating FAQ')),
      );
    }
  }
}

class FAQ {
  final String id;
  final String question;
  final String answer;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FAQ.fromMap(String id, Map<String, dynamic> data) {
    final String question = data['question'] ?? '';
    final String answer = data['answer'] ?? '';
    return FAQ(id: id, question: question, answer: answer);
  }
}
