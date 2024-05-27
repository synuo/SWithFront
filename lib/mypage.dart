import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/editprofile.dart';
import 'package:practice/neweditprofile.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'setting.dart';
import 'profile.dart';
import 'chat.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'home.dart';
import 'MyPostsPage.dart';
import 'MyApplicationsPage.dart';
import 'neweditprofile.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  @override
  Widget build(BuildContext context) {
    User? loggedInUser = Provider.of<UserProvider>(context).loggedInUser;

    int _currentIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지와 사용자 정보
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()), // profile.dart로 이동합니다.
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey, // 임시로 회색으로 지정
                    ),
                    child: Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          loggedInUser?.nickname ?? '', // 닉네임 표시
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          loggedInUser?.name ?? '', // 이름 표시
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // 프로필 수정으로 이동하는 기능 추가
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                          );
                        },
                        icon: Icon(Icons.edit),
                        color: Colors.indigo,
                        iconSize: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 구분선
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 10),
            // 기능 목록
            buildMenuItem('나의 모집 내역', Icons.arrow_forward_ios, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPostsPage()),
              );
            }),

            SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 10),
            buildMenuItem('나의 지원 내역', Icons.arrow_forward_ios, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApplicationsPage()),
              );
            }),
            SizedBox(height: 10),
            // 구분선
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 10),
            buildMenuItem('스크랩', Icons.arrow_forward_ios, () {
              // 스크랩으로 이동하는 기능 추가
            }),
            SizedBox(height: 10),
            // 구분선
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 10),
            buildMenuItem('피드백', Icons.arrow_forward_ios, () {
              // 피드백으로 이동하는 기능 추가
            }),
            SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 10),
            buildMenuItem('설정', Icons.arrow_forward_ios, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    SettingPage()), // setting.dart로 이동합니다.
              );
            }),
            SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.indigo,
              ),
            ),
            SizedBox(width: 5), // 텍스트와 아이콘이 겹치지 않게 간격 추가
            Icon(
              icon,
              size: 16,
              color: Colors.indigo,
            ), // 화살표 아이콘 추가
          ],
        ),
      ),
    );
  }
}
