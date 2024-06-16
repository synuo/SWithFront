import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:practice/post_detail.dart';
import 'common_object.dart';

class MyApplicationsPage extends StatefulWidget {
  @override
  _MyApplicationsPageState createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<Post> userApplications = [];

  @override
  void initState() {
    super.initState();
    fetchUserApplications();
  }

  Future<void> fetchUserApplications() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    final url = 'http://localhost:3000/userapplications/user/$userId/applications';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
            userApplications = (json.decode(response.body) as List)
                .map((data) => Post.fromJson(data))
                .toList();
        });
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (error) {
      print('Error fetching user applications: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나의 지원 내역'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Provider.of<UserProvider>(context).loggedInUser?.nickname ?? ''} 님의 지원 내역',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: userApplications.length,
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
                          Icon(_getCategoryIcon(userApplications[index].category)),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userApplications[index].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userApplications[index].study_name,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                userApplications[index].progress,
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
                              post_id: userApplications[index].post_id,
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
