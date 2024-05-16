import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? nickname;
  String? name;
  int? studentId;
  String? major;
  String? introduction;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/user/1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        setState(() {
          nickname = data['nickname']; // 가져온 사용자 정보 중 닉네임을 저장
          name = data['name']; // 가져온 사용자 정보 중 이름을 저장
          studentId = data['student_id']; // 학번 저장
          introduction = data['introduction']; // 자기 소개 저장

          // 사용자의 전공 정보 가져오기
          final majorId = data['major1']; // 사용자의 전공 ID
          if (majorId != null) {
            fetchMajorInfo(majorId); // 전공 ID를 이용하여 전공 정보를 가져옴
          }
        });
      } else {
        throw Exception('Failed to load user information');
      }
    } catch (error) {
      print('Error fetching user information: $error');
    }
  }

  // 전공 정보를 가져오는 메서드
  Future<void> fetchMajorInfo(int? majorId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        setState(() {
          major = data['major_name']; // 전공 이름을 저장
        });
      } else {
        throw Exception('Failed to load major information');
      }
    } catch (error) {
      print('Error fetching major information: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
      ),
      body: ProfileBody(
        nickname: nickname,
        name: name,
        studentId: studentId,
        major: major,
        introduction: introduction,
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final String? nickname;
  final String? name;
  final int? studentId;
  final String? major;
  final String? introduction;

  ProfileBody({this.nickname, this.name, this.studentId, this.major, this.introduction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        nickname ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${studentId ?? ''} / ${major ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '   $introduction',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Divider(),
                  Icon(Icons.star, size: 50, color: Colors.amber),
                  Icon(Icons.star, size: 50, color: Colors.amber),
                  Icon(Icons.star, size: 50, color: Colors.amber),
                  Icon(Icons.star_half, size: 50, color: Colors.amber),
                  Icon(Icons.star_border, size: 50, color: Colors.amber),
                  SizedBox(width: 5),
                  Text(
                    '3.5',
                    style: TextStyle(fontSize: 30),
                  ),
                  Text(
                    '   (7)',
                    style: TextStyle(fontSize: 20),
                  ),
                  Divider(),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '  Reviews',
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
    );
  }
}
