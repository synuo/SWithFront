import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice/post_detail.dart';
import 'chat.dart';
import 'common_widgets.dart';
import 'home.dart';
import 'mypage.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({Key? key}) : super(key: key);

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  int _currentIndex = 1;
  late List<Post> posts = []; // 게시물 목록 데이터

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse('http://localhost:3000/getposts');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<Post> fetchedPosts = jsonData.map((data) {
        return Post(
          post_id: data['post_id'] as int,
          title: data['title'] as String,
          category: data['category'] as String,
          view_count: data['view_count'] as int,
          progress: data['progress'] as String,
        );
      }).toList();

      setState(() {
        posts = fetchedPosts;
      });

    } else {
      throw Exception('Failed to load posts');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Board', style: TextStyle(color: Colors.white, fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Color(0xff19A7CE),
        centerTitle: true,
        actions: [
          SearchButton(onPressed: () {
            // 검색 버튼이 눌렸을 때 동작을 추가
          }),
        ],
      ),
      body: posts.isEmpty
          ? Center(
        child: CircularProgressIndicator(), // 또는 다른 로딩 상태 표시 위젯
      )
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          final Post post = posts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(postId: post.post_id),
                ),
              );
            },
            child: Container(
              height: 136,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${post.category} · ${post.progress} · ${post.view_count}",
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0: // 홈 아이콘
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
              break;
            case 1: // 게시판 아이콘
              // 현재 페이지
              break;
            case 2: // 채팅 아이콘
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen()));
              break;
            case 3: // 마이페이지 아이콘
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyPage()));
              break;
          }
        },
      ),
    );
  }
}

class Post {
  final int post_id;
  final String title;
  final String category;
  final int view_count;
  final String progress;

  Post(
      {required this.post_id,
        required this.title,
        required this.category,
        required this.view_count,
        required this.progress});
}