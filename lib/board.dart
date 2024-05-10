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
  late List<String> posts = []; // 게시물 목록 데이터

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse('http://localhost:3000/getposts');
    print(url);
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        posts = jsonData.map((data) => data['title'] as String).toList(); // JSON 데이터를 파싱하여 게시물 제목만 가져옵니다.
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
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(posts[index]),
            onTap: () {
              // 각 게시물을 눌렀을 때의 동작을 추가
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(), //여기에 post_id를 가지고 넘어가는 내용도 추가해야함
                ),
              );
            },
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
