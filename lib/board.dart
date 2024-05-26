import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice/post_detail.dart';
import 'addpost.dart';
import 'chat.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'home.dart';
import 'mypage.dart';

class BoardScreen extends StatefulWidget {
  final String? category; // 카테고리 파라미터 추가 (소윤)
  const BoardScreen({Key? key, this.category}) : super(key: key);

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
          writer_id: data['writer_id'] as int,
          create_at: DateTime.parse(data['create_at']),
          update_at: DateTime.parse(data['update_at']),
          study_name: data['study_name'] as String,
          content: data['study_name'] as String,
        );
      }).toList();

      setState(() {
        posts = fetchedPosts;

        // 카테고리가 '전체'가 아닌 경우 해당 카테고리의 게시물만 필터링  //추가 (소윤)
        if (widget.category != '전체') {
          fetchedPosts.retainWhere((post) => post.category == widget.category);
        }

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
          IconButton(
            icon: Icon(Icons.add), // 포스트 쓰기 아이콘
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPostScreen(),
                ),
              ).then((_) {
                fetchPosts(); // fetchPosts 함수 실행
              });
            },
          ),
          SearchButton(),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () => fetchPosts(),
        child: posts.isEmpty
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {
            final Post post = posts[index];
            return GestureDetector(
              onTap: () async {
                //조회수 증가
                await increaseViewCount(post.post_id);
                //화면 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post_id: post.post_id),
                  ),
                ).then((_) {
                  fetchPosts(); // fetchPosts 함수 실행
                });
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

      /*
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
      ),*/
    );
  }
}

