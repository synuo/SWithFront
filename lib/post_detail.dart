import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'chat.dart';
import 'common_widgets.dart';
import 'home.dart';
import 'mypage.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({Key? key}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  @override
  void initState() {
    super.initState();
    //fetchPosts();
  }

  Future<void> fetchPostDetails() async {
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
      });
    } else {
      throw Exception('Failed to load postdetail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Detail', style: TextStyle(color: Colors.white, fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Color(0xff19A7CE),
        centerTitle: true,
        actions: [
        ],
      ),
    );
  }
}
