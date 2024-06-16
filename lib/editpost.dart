import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'common_object.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  EditPostScreen({required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  String? _selectedCategory;
  late TextEditingController _titleController;
  late TextEditingController _studyNameController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  List<String> _tags = [];
  late int post_id;
  int tagMaxLength = 20;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _studyNameController = TextEditingController(text: widget.post.study_name);
    _contentController = TextEditingController(text: widget.post.content);
    _tagController = TextEditingController();
    _selectedCategory = widget.post.category;
    _tags = List.from(widget.post.tags);
    post_id = widget.post.post_id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _studyNameController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty ||
                    _selectedCategory == null ||
                    _studyNameController.text.isEmpty ||
                    _contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('모든 항목을 채워주세요.'),
                    ),
                  );
                } else {
                  editPost();
                }
              },
              child: Text('저장'),
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
                maxLines: null,
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
                spacing: 8.0,
                runSpacing: 8.0,
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

  Future<void> editPost() async {
    final url = Uri.parse('http://localhost:3000/editpost');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': post_id,
        'title': _titleController.text,
        'category': _selectedCategory,
        'study_name': _studyNameController.text,
        'content': _contentController.text,
      }),
    );
    if (response.statusCode == 200) {
      await editPostTag();
    } else {
      print('Failed to edit post. Status code: ${response.statusCode}');
      throw Exception('Failed to edit post');
    }
  }

  Future<void> editPostTag() async {
    print("editposttag 실행됨");
    final url = Uri.parse('http://localhost:3000/editposttag');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': post_id,
        'tags': _tags,
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('게시글 업데이트 완료'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      print('Failed to edit post tags. Status code: ${response.statusCode}');
      throw Exception('Failed to edit post tags');
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
        items: ["스터디", "공모전", "기타"]
            .map((category) =>
            DropdownMenuItem<String>(value: category, child: Text(category)))
            .toList(),
      );
}
