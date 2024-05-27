import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice/addadvancequestion.dart';
import 'package:practice/common_widgets.dart';
import 'package:provider/provider.dart';

import 'common_object.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _studyNameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _tags = [];
  late int post_id;
  int tagMaxLength = 20;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // 폼 유효성 검사
                if (_titleController.text.isEmpty ||
                    _selectedCategory == null ||
                    _studyNameController.text.isEmpty ||
                    _contentController.text.isEmpty) {
                  // 필수 필드가 비어있는 경우
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('모든 항목을 채워주세요.'),
                    ),
                  );
                } else {
                  addPost();
                }
              },
              child: Text('다음'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: _dropDown(underline: Container())),
              SizedBox(height: 12),
              TextField(
                controller: _studyNameController,
                decoration: InputDecoration(
                  labelText: 'Study Name',
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: '태그 추가',
                      ),
                      onFieldSubmitted: (value) {
                        _addTag();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0, //가로 간격
                runSpacing: 8.0, //세로 간격
                children: _tags.map((tag) => _buildTagItem(tag)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag() {
    if (_tagController.text.length <= tagMaxLength) {
      setState(() {
        final newTag = _tagController.text.trim();
        if (newTag.isNotEmpty) {
          _tags.add(newTag);
          _tagController.clear();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('태그는 ${tagMaxLength}자 이하여야 합니다.'),
        ),
      );
    }
  }

  Widget _buildTagItem(String tag) {
    return Chip(
      label: Text(tag),
      onDeleted: () {
        setState(() {
          _tags.remove(tag);
        });
      },
    );
  }

  Future<void> addPost() async {
    final url = Uri.parse('http://localhost:3000/addpost');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'writer_id' : loggedInUser?.user_id,
        'title': _titleController.text,
        'category': _selectedCategory,
        'study_name': _studyNameController.text,
        'content': _contentController.text,
      }),
    );
    if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        post_id = responseData['postId'];
        addPostTag();
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<void> addPostTag() async {
    final url = Uri.parse('http://localhost:3000/addposttag');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': post_id,
        'tags' : _tags
      }),
    );
    if (response.statusCode == 201) {

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddAQScreen(post_id: post_id)));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Widget _dropDown({
    Widget? underline,
    Widget? icon,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? iconEnabledColor,
  }) =>
      DropdownButton<String>(
          value: _selectedCategory,
          underline: underline,
          icon: icon,
          dropdownColor: Colors.white,
          style: style,
          iconEnabledColor: iconEnabledColor,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          hint: Text("카테고리 선택", style: hintStyle),
          items: ["스터디","공모전","기타"]
              .map((fruit) =>
              DropdownMenuItem<String>(value: fruit, child: Text(fruit)))
              .toList());
}