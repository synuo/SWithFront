import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> addPost() async {
    final url = Uri.parse('http://localhost:3000/addpost');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'category': _categoryController.text,
        'content': _contentController.text,
      }),
    );
    if (response.statusCode == 201) {
      // 게시글이 성공적으로 생성되었을 때
      Navigator.pop(context, true); // 현재 페이지를 닫고 이전 페이지로 돌아갑니다.
    } else {
      throw Exception('Failed to create post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: null, // 여러 줄 입력 가능하도록 설정
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 폼 유효성 검사
                if (_titleController.text.isEmpty ||
                    _categoryController.text.isEmpty ||
                    _contentController.text.isEmpty) {
                  // 필수 필드가 비어있는 경우
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                } else {
                  // 게시글 생성 요청
                  addPost();
                }
              },
              child: Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
