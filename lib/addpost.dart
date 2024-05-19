import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice/common_widgets.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _studyNameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Widget> questionFields = []; // 동적으로 추가될 위젯 목록

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
              ElevatedButton(
                onPressed: () {
                  // '사전질문'과 텍스트 필드 추가
                  setState(() {
                    questionFields.add(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('사전질문 ${questionFields.length + 1}'),
                          SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Answer',
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    );
                  });
                },
                child: Text('Add Question'),
              ),
              SizedBox(height: 24),
              // 동적으로 추가된 위젯들 표시
              ...questionFields,
            ],
          ),
        ),
      ),
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
        'writer_id' : 1, // TODO: 실제 user id 넣게 수정해야함
        'title': _titleController.text,
        'category': _selectedCategory,
        'study_name': _studyNameController.text,
        'content': _contentController.text,
      }),
    );
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('게시글 등록 완료'),
        ),
      );
      Navigator.pop(context, true);
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