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
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${Provider.of<UserProvider>(context).loggedInUser?.nickname ?? ''}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xff19A7CE),
                    ),
                  ),
                  TextSpan(
                    text: ' 님이 지원한',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: userApplications.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getCategoryIcon(userApplications[index].category),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userApplications[index].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xff19A7CE),
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

  Widget _getCategoryIcon(String category) {
    const double iconSize = 40.0;

    switch (category) {
      case '스터디':
        return Icon(Icons.book_outlined, color: Colors.blue, size: iconSize);
      case '공모전':
        return Icon(Icons.emoji_events_outlined, color: Colors.orange, size: iconSize);
      default:
        return Icon(Icons.category_outlined, color: Colors.grey, size: iconSize);
    }
  }
}
