import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice/updatepost.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'advance_a.dart';

class PostDetailScreen extends StatefulWidget {
  final int post_id;

  const PostDetailScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool isScrapped = false;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
      if (loggedInUser != null) {
        getScrap();
      }
    });
  }

  Future<Post> fetchPostDetails(int postId) async {
    final url = Uri.parse('http://localhost:3000/getposts/$postId');
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

  Future<void> getScrap() async {
    final url =
        Uri.parse('http://localhost:3000/getscrap').replace(queryParameters: {
      'user_id': loggedInUser?.user_id.toString(),
      'post_id': widget.post_id.toString(),
    });

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        if (responseData['isScrapped'] == 1) {
          isScrapped = true;
        } else {
          isScrapped = false;
        }
      });
    } else {
      throw Exception('Failed to get scrap status');
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
        'user_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 201) {
      print("Scrap added successfully");
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
        'user_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 200) {
      print("Scrap removed successfully");
    } else {
      throw Exception('Failed to delete scrap');
    }
  }

  Future<void> applyForPost() async {
    final url = Uri.parse('http://localhost:3000/getadvance_q')
        .replace(queryParameters: {
      'post_id': widget.post_id.toString(),
    });

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.length > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvanceAScreen(post_id: widget.post_id, advance_q: responseData),
          ),
        ).then((result) {
          if (result == true) {
            // Add application after completing AdvanceA
            addApplication();
          }
        });
      } else {
        // Add application directly
        addApplication();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지원 완료')),
        );
      }
    } else {
      throw Exception('Failed to check advance_q status');
    }
  }

  Future<void> addApplication() async {
    final url = Uri.parse('http://localhost:3000/addapplication');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'applicant_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 201) {
      print("Application added successfully");
    } else {
      throw Exception('Failed to add application');
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
          bool isWriter =
              loggedInUser != null && post.writer_id == loggedInUser!.user_id;

          return Scaffold(
            appBar: AppBar(
              title: Text(post.title),
              elevation: 0.0,
              backgroundColor: Color(0xff19A7CE),
              centerTitle: true,
              actions: [
                if (isWriter)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdatePostScreen(post: post)),
                      );
                    },
                  ),
                if (!isWriter)
                  IconButton(
                    icon: Icon(
                      isScrapped ? Icons.bookmark : Icons.bookmark_border,
                      color: isScrapped ? Colors.orange : Colors.white,
                    ),
                    onPressed: () {
                      if (loggedInUser != null) {
                        setState(() {
                          if (isScrapped) {
                            deleteScrap();
                          } else {
                            addScrap();
                          }
                          isScrapped = !isScrapped;
                        });
                      } else {
                        // Handle not logged in state
                        print("User is not logged in");
                      }
                    },
                  ),
                if (!isWriter)
                  //Todo : 중복지원 안되게 수정해야함 지금은 지원한 곳에 또 지원 가능
                  TextButton(
                    onPressed: () {
                      if (loggedInUser != null) {
                        applyForPost();
                      } else {
                        // Handle not logged in state
                        print("User is not logged in");
                      }
                    },
                    child: Text(
                      '지원하기',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
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
