import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';

// Question class definition
class Question {
  final int id;
  final int post_id;
  final String question;

  Question({
    required this.id,
    required this.post_id,
    required this.question,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      post_id: json['post_id'],
      question: json['question'],
    );
  }
}

class AdvanceAScreen extends StatefulWidget {
  final int post_id;

  const AdvanceAScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  _AdvanceAScreenState createState() => _AdvanceAScreenState();
}

class _AdvanceAScreenState extends State<AdvanceAScreen> {
  List<Question> questions = [];
  List<String> answers = [];
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url = Uri.parse('http://localhost:3000/getadvanceq/${widget.post_id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        questions = jsonData.map((data) => Question.fromJson(data)).toList();
        answers = List<String>.filled(questions.length, '');
      });
    } else {
      throw Exception('Failed to load advance questions');
    }
  }

  Future<void> submitAnswers() async {
    final url = Uri.parse('http://localhost:3000/addadvancea');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
        'answers': answers,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questions[index].question,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: submitAnswers,
        child: Icon(Icons.check),
        backgroundColor: Color(0xff19A7CE),
      ),
    );
  }
}
