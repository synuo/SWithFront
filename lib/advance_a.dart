import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';

class AdvanceQuestion {
  final int aq_id;
  final int post_id;
  final String aq_content;

  AdvanceQuestion({
    required this.aq_id,
    required this.post_id,
    required this.aq_content,
  });

  factory AdvanceQuestion.fromJson(Map<String, dynamic> json) {
    return AdvanceQuestion(
      aq_id: json['aq_id'],
      post_id: json['post_id'],
      aq_content: json['aq_content'],
    );
  }
}

class AdvanceAScreen extends StatefulWidget {
  final int post_id;
  final List<dynamic> advance_q;

  const AdvanceAScreen({Key? key, required this.post_id, required this.advance_q})
      : super(key: key);

  @override
  _AdvanceAScreenState createState() => _AdvanceAScreenState();
}

class _AdvanceAScreenState extends State<AdvanceAScreen> {
  List<AdvanceQuestion> questions = [];
  List<String> answers = [];
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    // Map advance_q to AdvanceQuestion objects
    questions = widget.advance_q
        .map((question) => AdvanceQuestion.fromJson(question))
        .toList();
    // Initialize answers list with empty strings
    answers = List<String>.filled(questions.length, '');
  }

  Future<void> addAdvanceA() async {
    final url = Uri.parse('http://localhost:3000/addadvance_a');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post_id,
        'aq_id': questions.map((question) => question.aq_id).toList(),
        'applicant_id': loggedInUser?.user_id,
        'aqa_content': answers,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지원 완료')),
      );
      Navigator.pop(context, true);
    } else {
      throw Exception('Failed to submit answers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advance Questions'),
        elevation: 0.0,
        backgroundColor: Color(0xff19A7CE),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '사전질문 ${questions[index].aq_id}:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      SizedBox(width: 8), // Add spacing between AQ ID and content
                      Expanded(
                        child: Text(
                          questions[index].aq_content,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    onChanged: (value) {
                      answers[index] = value;
                    },
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addAdvanceA,
        child: Text('제출'),
        backgroundColor: Color(0xff19A7CE),
      ),
    );
  }
}
