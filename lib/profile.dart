import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'common_object.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? major;
  List<dynamic>? reviews;
  double? averageRating;

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

  // 리뷰를 가져오는 메서드
  Future<void> fetchReviews() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    final url = 'http://localhost:3000/getreview/user/$userId/reviews';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        setState(() {
          reviews = data; // 리뷰 리스트를 저장
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final majorId = loggedInUser?.major1;
    fetchMajorInfo(majorId);
    fetchReviews();
  }

  double calculateAverageRating(List<dynamic>? reviews) {
    if (reviews == null || reviews.isEmpty) return 0.0;

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }
    return totalRating / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    User? loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    averageRating = calculateAverageRating(reviews);
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
      ),
      body: ProfileBody(
        nickname: loggedInUser?.nickname,
        name: loggedInUser?.name,
        studentId: loggedInUser?.student_id,
        major: major,
        introduction: loggedInUser?.introduction ?? '',
        reviews: reviews,
        averageRating: averageRating,
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
  final List<dynamic>? reviews;
  final double? averageRating;

  ProfileBody({this.nickname, this.name, this.studentId, this.major, this.introduction, this.reviews, this.averageRating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 정보 표시
          GestureDetector(
            onTap: () {
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
          Text(
            '리뷰',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (reviews != null && reviews!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 1; i < 6; i++)
                  Icon(
                    i <= averageRating! ? Icons.star : (i == averageRating! + 0.5 ? Icons.star_half : Icons.star_border),
                    size: 50,
                    color: Colors.amber,
                  ),
                SizedBox(width: 5),
                if (averageRating != null)
                  Text(
                    averageRating!.toStringAsFixed(1),
                    style: TextStyle(fontSize: 30),
                  ),
                if (reviews != null)
                  Text(
                    '   (${reviews!.length})',
                    style: TextStyle(fontSize: 20),
                  )
              ],
            ),
          if (reviews == null || reviews!.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Text(
                    '등록된 리뷰가 없습니다',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
          // 리뷰 표시
          if (reviews != null && reviews!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: reviews!.length,
                  itemBuilder: (context, index) {
                    final review = reviews![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(review['reviewer_id']?.toString() ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < review['rating'] ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          SizedBox(height: 5),
                          Text(review['content'] ?? ''),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
