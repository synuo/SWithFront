import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'otherprofile.dart';

class ApplicantsScreen extends StatefulWidget {
  final int post_id;

  const ApplicantsScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  _ApplicantsScreenState createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  List<Map<String, dynamic>> applicants = [];

  @override
  void initState() {
    super.initState();
    fetchApplicants();
  }

  Future<void> fetchApplicants() async {
    final url =
        Uri.parse('http://localhost:3000/getapplicants/${widget.post_id}');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          applicants = List<Map<String, dynamic>>.from(
              json.decode(response.body)['data']);
        });
      } else {
        throw Exception('Failed to load applicants');
      }
    } catch (error) {
      print('Error fetching applicants: $error');
    }
  }

  Future<void> updateApplicationStatus(int applicantId, String status) async {
    final url = Uri.parse('http://localhost:3000/patchapplicantstatus');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'applicant_id': applicantId,
          'status': status,
          'post_id': widget.post_id
        }),
      );

      if (response.statusCode == 200) {
        fetchApplicants(); // Reload applicants after update
      } else {
        throw Exception('Failed to update application status');
      }
    } catch (error) {
      print('Error updating application status: $error');
    }
  }

  void navigateToAdvanceQuestions(
      int postId, int applicantId, String nickname) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvanceAnswersScreen(
          postId: postId,
          applicantId: applicantId,
          nickname: nickname,
        ),
      ),
    );
  }

  void navigateToProfile(int senderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          senderId: senderId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '지원자 목록',
          style: TextStyle(
              color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: applicants.length,
                itemBuilder: (context, index) {
                  final applicant = applicants[index];

                  final String? profileIconString = applicant['user_image'];
                  final int? profileIconCodePoint = profileIconString != null && profileIconString.isNotEmpty
                      ? int.tryParse(profileIconString)
                      : null;
                  return GestureDetector(
                    onTap: () {
                      navigateToProfile(applicant['applicant_id']);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                child: profileIconCodePoint != null
                                    ? Icon(
                                  IconData(profileIconCodePoint, fontFamily: 'MaterialIcons'),
                                  size: 30,
                                  color: Color(0xff19A7CE),
                                )
                                    : Icon(Icons.person, size: 30,color: Color(0xff19A7CE)),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    applicant['nickname'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${applicant['student_id']} 학번  |  ${applicant['major1']}, ${applicant['major2'] ?? '-'}, ${applicant['major3'] ?? '-'}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.inactiveGray),
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  navigateToAdvanceQuestions(
                                      widget.post_id,
                                      applicant['applicant_id'],
                                      applicant['nickname']);
                                },
                                child: Text('사전질문 답변확인'),
                              ),
                              TextButton(
                                onPressed: applicant['status'] == null
                                    ? null
                                    : () {
                                        _showStatusChangeModal(
                                            context,
                                            applicant['applicant_id'],
                                            updateApplicationStatus);
                                      },
                                child: Text(applicant['status'] ??
                                    ''), // Null check added here
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvanceAnswersScreen extends StatelessWidget {
  final int postId;
  final int applicantId;
  final String nickname;

  const AdvanceAnswersScreen(
      {Key? key,
      required this.postId,
      required this.applicantId,
      required this.nickname})
      : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAdvanceAnswers() async {
    final url = Uri.parse('http://localhost:3000/getadvanceanswer');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'post_id': postId,
          'applicant_id': applicantId,
        }),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            json.decode(response.body)['data']);
      } else {
        throw Exception('Failed to load advance questions');
      }
    } catch (error) {
      print('Error fetching advance questions: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${nickname} 님의 사전질문 답변',
          style: TextStyle(
              color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAdvanceAnswers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('사전질문에 답변하지 않았습니다.'));
          }

          final questions = snapshot.data!;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${question['aq_id']}. ${question['aq_content']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          question['aqa_content'],
                          style: TextStyle(fontSize: 16),
                          maxLines: null, // Allow multiline text
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _showStatusChangeModal(
    BuildContext context, int applicantId, Function updateApplicationStatus) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '상태 변경',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('지원자의 상태를 변경하시겠습니까?'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    updateApplicationStatus(applicantId, '수락');
                  },
                  child: Text('수락'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    updateApplicationStatus(applicantId, '거절');
                  },
                  child: Text('거절'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
