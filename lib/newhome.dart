import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice/home.dart';
import 'package:practice/mypage.dart';
import 'package:practice/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'board.dart';
import 'chat.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'package:http/http.dart' as http;

class HomePage2 extends StatefulWidget {
  final int userId;
  const HomePage2({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MainhomeScreen(),
    BoardScreen(),
    ChatScreen(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // 현재 선택된 인덱스를 설정해 주세요
        onTap: _onItemTapped,
      ),
      );
  }
}

class MainhomeScreen extends StatefulWidget {

  const MainhomeScreen({Key? key,}) : super(key: key);

  @override
  State<MainhomeScreen> createState() => _MainhomeScreenState();
}

class _MainhomeScreenState extends State<MainhomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Main Home', style: TextStyle(color: Color(0xff19A7CE), fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          _buildNotificationButton(),
          _buildMenuButton(),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0), // 검색 바를 위한 높이 조정
          child: SearchButton(), // 검색 바 추가
        ),
      ),
      body : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 16.0),
                  CircularButton(
                    text: '스터디',
                    onTap: () {
                      //board 에서 카테고리가 스터디인 게시글만 보여줌
                    },
                  ),
                  CircularButton(
                    text: '공모전',
                    onTap: () {
                      //board 에서 카테고리가 공모전인 게시글만 보여줌
                    },
                  ),
                  CircularButton(
                    text: '기타',
                    onTap: () {
                      //board 에서 카테고리가 기타인 게시글만 보여줌
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '추천 글',  //우선 최신 게시물 5개?
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Replace with your actual item count
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 16.0),
                      child: ListTile(
                        title: Text('추천 글 제목 $index'),
                        subtitle: Text('추천 글 내용 $index'),
                        onTap: () {
                          // Add your onTap functionality here
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

          ),

        ),
      )

    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {
        print('Notification button clicked');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()), // NotificationPage는 알림 화면의 위젯입니다.
        );
      },
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        print('Menu button clicked');
      },
    );
  }
}
