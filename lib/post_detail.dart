import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'common_object.dart';

class PostDetailScreen extends StatefulWidget {
  final int post_id;

  const PostDetailScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool isScrapped = false;
  //Todo user_id를 기반으로 isScrapped를 최초 초기화 하는 함수 필요

  @override
  void initState() {
    super.initState();
  }

  Future<Post> fetchPostDetails(int postId) async {
    final url = Uri.parse('http://localhost:3000/getposts/${postId}');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final data = jsonData.isNotEmpty ? jsonData.first : null;
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
    } else {
      throw Exception('Failed to load post detail');
    }
  }


  Future<void> addScrap() async {
    final url = Uri.parse('http://localhost:3000/addscrap');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': 1, //TODO 실제 user id로 바꾸도록 코드 추가하기
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 201) {
      print("scrap 완료");

    } else {
      throw Exception('Failed to add scrap');
    }
  }

  Future<void> deleteScrap() async {
    final url = Uri.parse('http://localhost:3000/deletescrap');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': 1, //TODO 실제 user id로 바꾸도록 코드 추가하기
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 200) {
      print("scrap 취소 완료");

    } else {
      throw Exception('Failed to delete scrap');
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post>(
      future: fetchPostDetails(widget.post_id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              elevation: 0.0,
              backgroundColor: Color(0xff19A7CE),
              centerTitle: true,
              actions: [],
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final post = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(post.title),
              elevation: 0.0,
              backgroundColor: Color(0xff19A7CE),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    isScrapped ? Icons.bookmark : Icons.bookmark_border,
                    color: isScrapped ? Colors.orange : Colors.white, // 색상 변경
                  ),
                  onPressed: () {
                    setState(() {
                      // 스크랩 상태 변경
                      if (isScrapped) {
                        deleteScrap();
                      } else {
                        addScrap();
                      }
                      isScrapped = !isScrapped;
                    });
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  SizedBox(height: 10),
                  Text('Category: ${post.category}'),
                  Text('View Count: ${post.view_count}'),
                  Text('Progress: ${post.progress}'),
                  Text('Content: ${post.content}'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
