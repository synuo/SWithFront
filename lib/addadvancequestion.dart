import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common_object.dart';
import 'home.dart';

class AddAQScreen extends StatefulWidget {
  final int post_id;
  const AddAQScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  _AddAQScreenState createState() => _AddAQScreenState();
}

class _AddAQScreenState extends State<AddAQScreen> {
  List<TextEditingController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    User? loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    final user_id = loggedInUser?.user_id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '사전 질문 작성',
          style: TextStyle(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // AppBar의 뒤로 가기 버튼 비활성화
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_controllers != null){
                  addAdvanceQ();
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user_id: user_id!)));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('게시글 등록 완료'),
                  ),
                );
              },
              child: Text('완료'),
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
              ..._controllers.map((controller) {
                int index = _controllers.indexOf(controller);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: '사전질문 ${index + 1}',
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controllers.add(TextEditingController());
                  });
                },
                child: Text('사전질문 추가'),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addAdvanceQ() async {
    final url = Uri.parse('http://localhost:3000/addadvance_q');
    final aqContentList = _controllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .toList();
    final aqIdList = List<int>.generate(aqContentList.length, (index) => index + 1);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post_id,
        'aq_id': aqIdList.isNotEmpty ? aqIdList : null,
        'aq_content': aqContentList.isNotEmpty ? aqContentList : null,
      }),
    );
    if (response.statusCode == 201) {
      print("사전질문 등록 완료");
    } else {
      throw Exception('사전질문 등록 실패');
    }
  }
}
