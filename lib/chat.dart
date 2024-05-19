import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'board.dart';
import 'common_widgets.dart';
import 'home.dart';
import 'mypage.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> studyNames = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/viewchatroom'),
      body: {'userId': '1'}, // 유저 아이디를 전송
    );

    if (response.statusCode == 200) {
      // 정상적으로 응답을 받았을 때
      final data = jsonDecode(response.body);
      setState(() {
        studyNames = List<String>.from(data['data'].map((item) => item['study_name'])); // 응답에서 study_name들을 추출합니다
      });
    } else {
      // 오류가 발생했을 때
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: studyNames.isEmpty
          ? Center(child: Text('현재 가입한 스터디가 없습니다.'))
          : ListView.builder(
        itemCount: studyNames.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(studyNames[index]),
              onTap: () {
                // 채팅방으로 이동하는 코드 추가
                //Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen(studyName: studyNames[index])));
              },
            ),
          );
        },
      ),
      /*
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0: // 홈 아이콘
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
              break;
            case 1: // 게시판 아이콘
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BoardScreen()));
              break;
            case 2: // 채팅 아이콘

              break;
            case 3: // 마이페이지 아이콘
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyPage()));
              break;
          }
        },
      ),*/
    );
  }
}