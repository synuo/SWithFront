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
  @override
  void initState() {
    super.initState();
  }

  Future<Post> fetchPostDetails(int postId) async {
    final url = Uri.parse('http://localhost:3000/getposts/${postId}');
    print(url);
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
              actions: [],
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
