import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/post_detail.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';

class ApplicantsScreen extends StatefulWidget {
  final int post_id;

  const ApplicantsScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  _ApplicantsScreenState createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  List<Post> userScraps = []; //Todo user 내용으로 수정

  @override
  void initState() {
    super.initState();
    //fetchApplicants();
  }

  Future<void> fetchApplicants() async {
    final url =
    Uri.parse('http://localhost:3000/getscrap').replace(queryParameters: {
      'user_id': widget.post_id.toString(),
    });

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
          userScraps = (json.decode(response.body) as List)
              .map((data) => Post.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching user posts: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지원자 목록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: userScraps.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(10), // 테두리 내부 여백
                    margin: EdgeInsets.symmetric(vertical: 5), // 테두리 외부 여백
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // 테두리 색상 및 두께 지정
                      borderRadius: BorderRadius.circular(10), // 테두리 모서리 둥글기
                    ),
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_getCategoryIcon(userScraps[index].category)),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userScraps[index].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userScraps[index].study_name,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                userScraps[index].progress,
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to the post detail screen with the post_id
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                              post_id: userScraps[index].post_id,
                            ),
                          ),
                        );
                      },
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '스터디':
        return Icons.book;
      case '공모전':
        return Icons.emoji_events;
      default:
        return Icons.category;
    }
  }
}
