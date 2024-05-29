import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'profile.dart';
import 'writereview.dart';

class UserProfileScreen extends StatefulWidget {
  final int senderId;

  UserProfileScreen({required this.senderId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;
  String? major; // 추가된 전공 변수
  Map<String, dynamic>? userData; // 사용자 데이터

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/user/${widget.senderId}'));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      userData = Map<String, dynamic>.from(decodedData); // 사용자 데이터 저장
      fetchMajorInfo(); // 사용자의 전공 정보를 가져옴
      return userData!;
    } else {
      print('Failed to load user data: ${response.statusCode}');
      return {};
    }
  }

  // 사용자의 전공 정보를 가져오는 메서드
  Future<void> fetchMajorInfo() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/${userData!['major1']}'));
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
        title: Text('User Profile'),
      ),
      body: FutureBuilder(
        future: _userFuture,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userData = snapshot.data!;
            // ProfileBody 위젯으로 사용자 정보를 전달하여 표시
            return Column(
              children: [
                Expanded(
                  child: ProfileBody(
                    nickname: userData['nickname'] ?? '',
                    name: userData['name'] ?? '',
                    studentId: userData['student_id'] ?? 0,
                    major: major ?? '',
                    introduction: userData['introduction'] ?? '',
                    reviews: userData['reviews'] ?? [],
                    averageRating: userData['average_rating'] ?? 0.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteReviewScreen(userId: widget.senderId),
                        ),
                      );
                    },
                    child: Text('Write a Review'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
