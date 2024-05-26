import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'board.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'home.dart';
import 'mypage.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> chatRooms = [];
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getchatrooms'),
      body: {'userId': loggedInUser?.user_id.toString()},
      // 유저 아이디를 전송
    );

    if (response.statusCode == 200) {
      // 정상적으로 응답을 받았을 때
      final data = jsonDecode(response.body);
      setState(() {
        chatRooms = List<Map<String, dynamic>>.from(data['data']);//room_id, study_name
      });
    } else {
      // 오류가 발생했을 때
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    //int _currentIndex = 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: chatRooms.isEmpty
          ? Center(child: Text('현재 가입한 스터디가 없습니다.'))
          : ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(chatRooms[index]['study_name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      roomId: chatRooms[index]['room_id'].toString(),
                      studyName: chatRooms[index]['study_name'],
                    ),
                  ),
                );
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