import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
        backgroundColor: Colors.green,
      ),
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
