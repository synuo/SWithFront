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

//05.26 수정본
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
        currentIndex: _currentIndex,
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
  String? searchQuery;

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
        return Post.fromJson(data);
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

  Future<void> increaseViewCount(int post_id) async {
    final url = Uri.parse('http://localhost:3000/view_count/${post_id}');

    try {
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('조회수가 성공적으로 증가되었습니다.');
      } else if (response.statusCode == 404) {
        print('해당 post_id를 가진 포스트를 찾을 수 없습니다.');
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
      fetchTopPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'SWith',
            style: TextStyle(
                color: Colors.black,
                fontSize: 40.0,
                fontFamily: 'Teko',
                shadows: [
                  Shadow(
                    offset: Offset(2.0,2.0),
                    blurRadius: 5.0,
                    color: Color.fromARGB(50, 0, 0, 0),
                  )
                ]
            ),

          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          //_buildSearchButton()
          //_buildNotificationButton(),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:  Search(onSearch: handleSearch),
          ),
        ),
      ),
      body : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '  카테고리별 게시판 바로가기',  //조회수가 높은 게시물 5개
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Spacer(), // 이 부분을 추가하여 왼쪽 간격을 조절
                  CircularButton(
                    text: '스터디',
                    icon: Icons.book_outlined, // 적절한 아이콘 선택
                    onTap: () {
                      //board 에서 카테고리가 스터디인 게시글만 보여줌
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardScreen(category: '스터디',)), // NotificationPage는 알림 화면의 위젯입니다.
                      );
                      print("카테고리 : 스터디");
                    },
                  ),
                  Spacer(),
                  CircularButton(
                    text: '공모전',
                    icon: Icons.emoji_events_outlined,
                    onTap: () {
                      //board 에서 카테고리가 공모전인 게시글만 보여줌
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardScreen(category: '공모전',)), // NotificationPage는 알림 화면의 위젯입니다.
                      );
                      print("카테고리 : 공모전");
                    },
                  ),
                  Spacer(),
                  CircularButton(
                    text: '기타',
                    icon: Icons.category_outlined,
                    onTap: () {
                      //board 에서 카테고리가 기타인 게시글만 보여줌
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BoardScreen(category: '기타',)), // NotificationPage는 알림 화면의 위젯입니다.
                      );
                      print("카테고리 : 기타");
                    },
                  ),
                  Spacer(),
                ],
              ),

              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '  조회수 Top 5 게시글',  //조회수가 높은 게시물 5개
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5.0),
              Expanded(
                child: topPosts.isEmpty ? Center(child: CircularProgressIndicator()) : ListView.builder(
                  itemCount: topPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Post post = topPosts[index];
                    return GestureDetector(
                      onTap: () async {
                        //조회수 증가
                        await increaseViewCount(post.post_id);
                        //해당 게시글로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post_id: post.post_id),
                          ),
                        ).then((_) {
                          fetchTopPosts(); // fetchPosts 함수 실행  //이거까지 해야 조회수가 반영됨 (왜지)
                        });;
                      },
                      child: Container(
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff19A7CE)),
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
                                  Row(
                                    children: [
                                      if (post.category == "스터디") ...[
                                        Icon(Icons.book, size: 20.0, color: Color(0xff19A7CE)),
                                      ] else if (post.category == "공모전") ...[
                                        Icon(Icons.emoji_events, size: 20.0, color: Color(0xff19A7CE)),
                                      ] else if (post.category == "기타") ...[
                                        Icon(Icons.category, size: 20.0, color: Color(0xff19A7CE),),
                                      ],
                                      const SizedBox(width: 8), // 아이콘과 제목 사이의 간격
                                      Expanded(
                                        child: Text(
                                          post.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  /*
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                   */
                                  const SizedBox(height: 8),
                                  Text(
                                    "${post.category} · ${post.progress} · ${post.view_count} views",
                                    //style: Theme.of(context).textTheme.caption,
                                    style: const TextStyle(
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4.0,
                                    runSpacing: 2.0,
                                    children: post.tags
                                        .map((tag) => Text(
                                      '#$tag',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 13.0),
                                    ))
                                        .toList(),
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

  Widget _buildSearchButton() {
    return IconButton(
      icon: Icon(Icons.search_outlined),
      onPressed: () {
        print('Search button clicked');
      },
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      icon: Icon(Icons.notifications_none_outlined),
      onPressed: () {
        print('Notification button clicked');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()), // NotificationPage는 알림 화면의 위젯입니다.
        );
      },
    );
  }

}
