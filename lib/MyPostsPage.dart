import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/post_detail.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';

class MyPostsPage extends StatefulWidget {
  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<Post> userPosts = [];

  @override
  void initState() {
    super.initState();
    fetchUserPosts();
  }

  Future<void> fetchUserPosts() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    final url = 'http://localhost:3000/userPosts/user/$userId/posts';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          userPosts = (json.decode(response.body) as List)
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
        title: Text(
          '나의 모집 내역',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: userPosts.length,
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
                          _getCategoryIcon(userPosts[index].category),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userPosts[index].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xff19A7CE)
                                  ),
                                ),
                                Text(
                                  userPosts[index].study_name,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                userPosts[index].progress,
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
                              post_id: userPosts[index].post_id,
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
    const double iconSize = 40.0; // Define the size of the icons

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