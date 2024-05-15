import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPage(),
    );
  }
}

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()), // ProfileScreen으로 이동
            );
          },
          child: Text('프로필'), // 프로필 버튼
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
      ),
      body: ProfileBody(),
    );
  }
}

class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Text(
                          '사용자 전공 / 사용자 학번',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10), // 자기소개와 이전 위젯 사이 간격 조정
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10), // 자기소개와 이전 위젯 사이 간격 조정
            Text(
              '   안녕하세요 안뇽안뇽 내가누구게',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            // 별점과 리뷰
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Divider(),
                    Icon(Icons.star, size: 50, color: Colors.amber), // 별 아이콘 크기 조정
                    Icon(Icons.star, size: 50, color: Colors.amber),
                    Icon(Icons.star, size: 50, color: Colors.amber),
                    Icon(Icons.star_half, size: 50, color: Colors.amber),
                    Icon(Icons.star_border, size: 50, color: Colors.amber),
                    SizedBox(width: 5),
                    Text(
                      '3.5', // 리뷰/별점
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      '   (7)', // 리뷰 개수
                      style: TextStyle(fontSize: 20),
                    ),
                    Divider(),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '  Reviews', // 리뷰 텍스트
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
