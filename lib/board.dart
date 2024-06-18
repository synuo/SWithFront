import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice/post_detail.dart';
import 'addpost.dart';
import 'common_object.dart';
import 'common_widgets.dart';

class BoardScreen extends StatefulWidget {
  final String? category; // 카테고리 파라미터
  const BoardScreen({Key? key, this.category}) : super(key: key);

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late List<Post> posts = []; // 게시물 목록 데이터
  String? searchQuery;  // 검색
  String selectedFilter = '모집중';

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
        return Post.fromJson(data);
      }).toList();

      setState(() {
        posts = fetchedPosts;

        // 카테고리가 '전체'가 아닌 경우 해당 카테고리의 게시물만 필터링
        if (widget.category != '전체') {
          fetchedPosts.retainWhere((post) => post.category == widget.category);
        }
        // 검색어가 있는 경우 검색어가 포함된 게시물만 필터링
        if (searchQuery != null && searchQuery!.isNotEmpty) {
          posts = posts.where((post) =>
          post.title.contains(searchQuery!) ||
              post.content.contains(searchQuery!) ||
              post.study_name.contains(searchQuery!)
          ).toList();
        }
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
      fetchPosts();
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    fetchPosts(); // 서버에서 데이터를 다시 가져와 필터링을 적용
  }

  List<Post> getFilteredPosts() {
    if (selectedFilter == '전체') {
      return posts;
    } else {
      return posts.where((post) => post.progress == selectedFilter).toList();
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
          '게시판',
          style: TextStyle(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list), // 필터 버튼 아이콘
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.edit), // 포스트 쓰기 아이콘
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
        ],
      ),
      body: Column(
        children: [
          Search(onSearch: handleSearch),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => fetchPosts(),
              child: posts.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : ListView.builder(
                itemCount: getFilteredPosts().length,
                itemBuilder: (BuildContext context, int index) {
                  final Post post = getFilteredPosts()[index];
                  return GestureDetector(
                    onTap: () async {
                      // 조회수 증가
                      await increaseViewCount(post.post_id);
                      // 화면 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostDetailScreen(post_id: post.post_id),
                        ),
                      ).then((_) {
                        fetchPosts();
                      });
                    },
                    child: Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${post.category} · ${post.progress} · ${post.view_count}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
                                  fontSize: 12.0),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('필터 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <String>[
              '전체',
              '모집중',
              '모집 종료',
              '추가 모집',
              '스터디 종료'
            ].map((filter) {
              return RadioListTile(
                title: Text(filter),
                value: filter,
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                  applyFilter(selectedFilter);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
