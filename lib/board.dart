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
  String? searchQuery; // 검색
  Set<String> selectedProgressFilters = {'모집중'};
  Set<String> selectedCategoryFilters = {'스터디','공모전','기타'};
  bool isLoading = true; // 데이터를 불러오는 중인지 여부

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true; // 데이터를 불러오기 시작
    });

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
          posts.retainWhere((post) => post.category == widget.category);
        }

        // 검색어가 있는 경우 검색어가 포함된 게시물만 필터링
        if (searchQuery != null && searchQuery!.isNotEmpty) {
          posts = posts
              .where((post) =>
          post.title.contains(searchQuery!) ||
              post.content.contains(searchQuery!) ||
              post.study_name.contains(searchQuery!))
              .toList();
        }

        isLoading = false; // 데이터를 불러오기 완료
      });
    } else {
      setState(() {
        isLoading = false; // 데이터를 불러오기 실패
      });
      throw Exception('Failed to load posts');
    }
  }


  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
      fetchPosts();
    });
  }


  void toggleProgressFilter(String filter) {
    setState(() {
      if (selectedProgressFilters.contains(filter)) {
        selectedProgressFilters.remove(filter);
      } else {
        selectedProgressFilters.add(filter);
      }
    });
    fetchPosts();
  }

  void toggleCategoryFilter(String filter) {
    setState(() {
      if (selectedCategoryFilters.contains(filter)) {
        selectedCategoryFilters.remove(filter);
      } else {
        selectedCategoryFilters.add(filter);
      }
    });
    fetchPosts();
  }

  List<Post> getFilteredPosts() {
    List<Post> filteredPosts = posts;

    // Progress 필터 적용
    if (selectedProgressFilters.isNotEmpty) {
      filteredPosts = filteredPosts
          .where((post) => selectedProgressFilters.contains(post.progress))
          .toList();
    }

    // Category 필터 적용
    if (selectedCategoryFilters.isNotEmpty) {
      filteredPosts = filteredPosts
          .where((post) => selectedCategoryFilters.contains(post.category))
          .toList();
    }

    return filteredPosts;
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
        title: SearchBar(onSearch: handleSearch),
        actions: [
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 45, // 적절한 높이를 설정하여 버튼이 잘리지 않도록 합니다
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    _buildCategoryFilterButton('스터디'),
                    _buildCategoryFilterButton('공모전'),
                    _buildCategoryFilterButton('기타'),
                    _buildProgressFilterButton('모집중'),
                    _buildProgressFilterButton('모집 종료'),
                    _buildProgressFilterButton('추가 모집'),
                    _buildProgressFilterButton('스터디 종료'),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => fetchPosts(),
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : posts.isEmpty
                  ? const Center(
                child: Text('적합한 게시글이 존재하지 않습니다.'),
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
                        border: Border.all(
                            color: const Color(0xff19A7CE)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (post.category == "스터디") ...[
                                Icon(Icons.book,
                                    size: 20.0,
                                    color: Color(0xff19A7CE)),
                              ] else
                                if (post.category == "공모전") ...[
                                  Icon(Icons.emoji_events,
                                      size: 20.0,
                                      color: Color(0xff19A7CE)),
                                ] else
                                  if (post.category == "기타") ...[
                                    Icon(Icons.category,
                                        size: 20.0,
                                        color: Color(0xff19A7CE)),
                                  ],
                              const SizedBox(width: 8),
                              // 아이콘과 제목 사이의 간격
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
                          const SizedBox(height: 4),
                          Text(
                            "${post.category} · ${post.progress} · ${post
                                .view_count} views",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4.0,
                            runSpacing: 2.0,
                            children: post.tags
                                .map((tag) =>
                                Text(
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressFilterButton(String progress) {
    final isSelected = selectedProgressFilters.contains(progress);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0), // 버튼 간의 간격 설정
      child: ElevatedButton(
        onPressed: () {
          toggleProgressFilter(progress);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xff19A7CE) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          minimumSize: Size(80, 40), // 버튼의 가로 길이를 100으로 설정
        ),
        child: Text(
          progress,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterButton(String category) {
    final isSelected = selectedCategoryFilters.contains(category);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0), // 버튼 간의 간격 설정
      child: ElevatedButton(
        onPressed: () {
          toggleCategoryFilter(category);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xff19A7CE) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          minimumSize: Size(80, 40), // 버튼의 가로 길이를 100으로 설정
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

  class SearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  bool _isActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!_isActive)
          Text("전체 게시글",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _isActive
                  ? Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0)),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                            hintText: '글 제목, 내용, 해시태그 등으로 검색해보세요.',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isActive = false;
                                  });
                                  widget.onSearch('');
                                  _searchController.clear();
                                },
                                icon: const Icon(Icons.close))),
                        onSubmitted: widget.onSearch,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _isActive = true;
                        });
                      },
                      icon: const Icon(Icons.search)),
            ),
          ),
        ),
      ],
    );
  }
}
