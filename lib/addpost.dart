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
    loggedInUser =
        Provider.of<UserProvider>(context, listen: false).loggedInUser;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '새 게시글',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '카테고리',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '스터디, 공모전, 기타 중 하나의 카테고리를 선택해주세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildCategoryButton('스터디'),
                  SizedBox(width: 10),
                  _buildCategoryButton('공모전'),
                  SizedBox(width: 10),
                  _buildCategoryButton('기타'),
                ],
              ),
              SizedBox(height: 25),
              _buildTextField(
                title: '게시글 제목',
                hintText: '',
                controller: _titleController,
                description: '스터디에 대한 한줄 소개를 적어주세요.',
              ),
              SizedBox(height: 25),
              _buildTextField(
                title: '스터디명',
                hintText: '',
                controller: _studyNameController,
                description: '채팅방 개설시 사용할 이름을 정해주세요.',
              ),
              SizedBox(height: 25),
              _buildTextField(
                title: '본문',
                hintText: '',
                controller: _contentController,
                isMultiline: true,
                description: '스터디 계획, 일정 등 스터디의 전반적인 내용에 대해서 기재해주세요.',
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '해시태그',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '태그를 입력한 뒤 오른쪽의 + 버튼을 눌러주세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
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
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xff19A7CE)), // 버튼 배경색
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // 버튼 모서리 둥글기 설정
                    ),
                  ),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: EdgeInsets.symmetric(vertical: 15.0), // 버튼 내부 패딩
                  child: Center(
                    child: Text(
                      '다음으로',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedCategory == category ? Color(0xff19A7CE) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        minimumSize: Size(20, 40),
      ),
      child: Text(
        category,
        style: TextStyle(
            color:
                _selectedCategory == category ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold),
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
      label: Text(
        tag,
        style: TextStyle(color: Colors.black), // Label text color
      ),
      backgroundColor: Colors.white, // Background color
      shape: StadiumBorder(
        side: BorderSide(
          color: Colors.grey, // Border color
          width: 1.0, // Border width
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
        color: Colors.blueGrey, // Delete icon color
      ),
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
        'writer_id': loggedInUser?.user_id,
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
      body: jsonEncode({'post_id': post_id, 'tags': _tags}),
    );
    if (response.statusCode == 201) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AddAQScreen(post_id: post_id)));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Widget _buildTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    bool isMultiline = false,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (description != null) // Render description if provided
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: isMultiline ? null : 1,
            minLines: isMultiline ? 5 : 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }
}
