import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice/mypage.dart';
import 'package:practice/notifications.dart';
import 'package:practice/post_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'board.dart';
import 'chat.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'package:http/http.dart' as http;

//05.20 수정본
class HomePage extends StatefulWidget {
  final int user_id;
  const HomePage({Key? key, required this.user_id}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MainhomeScreen(),
    BoardScreen(category: '전체'),  // 기본값을 전체로 설정
    ChatScreen(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // 현재 선택된 인덱스를 설정해 주세요
        onTap: _onItemTapped,
      ),
      );
  }
}

class MainhomeScreen extends StatefulWidget {

  const MainhomeScreen({Key? key,}) : super(key: key);

  @override
  State<MainhomeScreen> createState() => _MainhomeScreenState();
}

class _MainhomeScreenState extends State<MainhomeScreen> {
  late List<Post> topPosts = [];

  @override
  void initState() {
    super.initState();
    fetchTopPosts();
  }

  Future<void> fetchTopPosts() async {
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
          writer_id: data['writer_id'] as int,
          create_at: DateTime.parse(data['create_at']),
          update_at: DateTime.parse(data['update_at']),
          study_name: data['study_name'] as String,
          content: data['content'] as String,
        );
      }).toList();

      // Sort the posts by view_count in descending order
      fetchedPosts.sort((a, b) => b.view_count.compareTo(a.view_count));
      // Get the top 5 posts
      setState(() {
        topPosts = fetchedPosts.take(5).toList();
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
          'Main Home', style: TextStyle(color: Color(0xff19A7CE), fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          _buildNotificationButton(),
          _buildMenuButton(),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0), // 검색 바를 위한 높이 조정
          child: SearchButton(), // 검색 바 추가
        ),
      ),
      body : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 16.0),
                  CircularButton(
                    text: '스터디',
                    onTap: () {
                      //TODO : board 에서 카테고리가 스터디인 게시글만 보여줌
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardScreen(category: '스터디',)), // NotificationPage는 알림 화면의 위젯입니다.
                      );
                    },
                  ),
                  CircularButton(
                    text: '공모전',
                    onTap: () {
                      //TODO : board 에서 카테고리가 공모전인 게시글만 보여줌
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardScreen(category: '공모전',)), // NotificationPage는 알림 화면의 위젯입니다.
                      );
                    },
                  ),
                  CircularButton(
                    text: '기타',
                    onTap: () {
                      //TODO : board 에서 카테고리가 기타인 게시글만 보여줌
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardScreen(category: '기타',)), // NotificationPage는 알림 화면의 위젯입니다.
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '추천 글',  //우선 최신 게시물 5개?
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: topPosts.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: topPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Post post = topPosts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post_id: post.post_id),
                          ),
                        );
                      },
                      child: Container(
                        height: 100,
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
                                    "${post.category} · ${post.progress} · ${post.view_count} views",
                                    //style: Theme.of(context).textTheme.caption,
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
              ),
            ],

          ),

        ),
      )

    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {
        print('Notification button clicked');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()), // NotificationPage는 알림 화면의 위젯입니다.
        );
      },
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        print('Menu button clicked');
      },
    );
  }
}
