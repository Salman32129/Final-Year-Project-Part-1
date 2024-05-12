import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteFAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete FAQ'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('FAQs').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<FAQ> faqs = snapshot.data!.docs
              .map((doc) =>
                  FAQ.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          return DataTable(
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
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteFAQ(faq.id, context);
                        },
                      ),
                    ),
                  ]),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Future<void> deleteFAQ(String faqId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('FAQs').doc(faqId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAQ deleted successfully')),
      );
    } catch (e) {
      print('Error deleting FAQ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting FAQ')),
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
