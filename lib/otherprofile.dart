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
  String? major;
  Map<String, dynamic>? userData;
  bool canWriteReview = true;
  double averageRating = 0.0; // 기본값 설정
  List<dynamic> reviews = []; // 기본값 설정

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/user/${widget.senderId}'));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      userData = Map<String, dynamic>.from(decodedData);
      await fetchMajorInfo();
      await checkReviewStatus();
      await fetchReviews();
      return userData!;
    } else {
      print('Failed to load user data: ${response.statusCode}');
      return {};
    }
  }

  Future<void> fetchMajorInfo() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/${userData!['major1']}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          major = data['major_name'];
        });
      } else {
        throw Exception('Failed to load major information');
      }
    } catch (error) {
      print('Error fetching major information: $error');
    }
  }

  double calculateAverageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }
    return totalRating / reviews.length;
  }

  Future<void> checkReviewStatus() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final user_id = loggedInUser?.user_id;
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/checkreview/${widget.senderId}/$user_id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          canWriteReview = data.isEmpty;
          print(canWriteReview);
        });
      } else {
        throw Exception('Failed to check review status');
      }
    } catch (error) {
      print('Error checking review status: $error');
    }
  }

  Future<String> fetchReviewerNickname(int reviewerId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/user/$reviewerId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        return data['nickname']; // 닉네임 반환
      } else {
        throw Exception('Failed to load user information');
      }
    } catch (error) {
      print('Error fetching user information: $error');
      return 'Unknown'; // 에러 발생 시 기본 닉네임
    }
  }

  Future<void> fetchReviews() async {
    final url = 'http://localhost:3000/getreview/user/${widget.senderId}/reviews';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> updatedReviews = [];

        for (var review in data) {
          String nickname = await fetchReviewerNickname(review['reviewer_id']);
          review['reviewer_nickname'] = nickname;
          updatedReviews.add(review);
        }

        setState(() {
          reviews = updatedReviews;
          averageRating = calculateAverageRating(reviews);
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
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

            return Column(
              children: [
                Expanded(
                  child: ProfileBody(
                    nickname: userData['nickname'] ?? '',
                    name: userData['name'] ?? '',
                    studentId: userData['student_id'] ?? 0,
                    major: major ?? '',
                    introduction: userData['introduction'] ?? '',
                    reviews: reviews,
                    averageRating: averageRating,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      minimumSize: Size(200, 10),
                    ),
                    onPressed: canWriteReview
                        ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteReviewScreen(userId: widget.senderId),
                        ),
                      );
                    }
                        : null,
                    child: Text(
                      '리뷰 작성',
                      style: TextStyle(fontSize: 22),
                    ),
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
