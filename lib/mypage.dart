import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:practice/userinfo.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:practice/profile.dart'; // ProfileScreen을 import

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
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
                          '사용자 닉네임',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '사용자 이름',
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
                          color: Colors.indigo, // 톱니바퀴 아이콘을 둘러싼 상자 모양 선의 색상 지정
                          width: 1, // 톱니바퀴 아이콘을 둘러싼 상자 모양 선의 두께 지정
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // 프로필 수정으로 이동하는 기능 추가
                        },
                        icon: Icon(Icons.settings),
                        color: Colors.indigo, // 톱니바퀴 아이콘의 색상 지정
                        iconSize: 35, // 톱니바퀴 아이콘의 크기 조정
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 구분선
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 20),
            // 기능 목록
            buildMenuItem('나의 모집 현황', Icons.arrow_forward_ios, () {
              // 나의 모집 현황으로 이동하는 기능 추가
            }),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 20),
            buildMenuItem('나의 지원 현황', Icons.arrow_forward_ios, () {
              // 나의 지원 현황으로 이동하는 기능 추가
            }),
            SizedBox(height: 20),
            // 구분선
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 20),
            buildMenuItem('스크랩', Icons.arrow_forward_ios, () {
              // 스크랩으로 이동하는 기능 추가
            }),
            SizedBox(height: 20),
            // 구분선
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 20),
            buildMenuItem('피드백', Icons.arrow_forward_ios, () {
              // 피드백으로 이동하는 기능 추가
            }),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 20),
            buildMenuItem('설정', Icons.arrow_forward_ios, () {
              // 설정으로 이동하는 기능 추가
            }),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey), // 회색 구분선 추가
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
