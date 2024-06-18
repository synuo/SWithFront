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
  String? major, major2, major3;
  List<dynamic>? reviews;
  double? averageRating;

  // 전공 정보를 가져오는 메서드
  Future<void> fetchMajorInfo(int? majorId, int? majorId2, int? majorId3) async {
    try {
      // Fetch major
      final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        setState(() {
          major = data['major_name']; // 전공 이름을 저장
        });
      } else {
        throw Exception('Failed to load major information');
      }

      // Fetch major2
      final response2 = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId2'));
      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        setState(() {
          major2 = data2['major_name']; // Save major2
        });
      } else {
        throw Exception('Failed to load major2 information');
      }

      // Fetch major3
      final response3 = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId3'));
      if (response3.statusCode == 200) {
        final data3 = json.decode(response3.body);
        setState(() {
          major3 = data3['major_name']; // Save major3
        });
      } else {
        throw Exception('Failed to load major3 information');
      }
    } catch (error) {
      print('Error fetching major information: $error');
    }
  }

  // 유저 닉네임을 가져오는 메서드
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

  // 리뷰를 가져오는 메서드
  Future<void> fetchReviews() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    final url = 'http://localhost:3000/getreview/user/$userId/reviews';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        List<dynamic> updatedReviews = [];

        // 각 리뷰의 닉네임 가져오기
        for (var review in data) {
          String nickname = await fetchReviewerNickname(review['reviewer_id']);
          review['reviewer_nickname'] = nickname;
          updatedReviews.add(review);
        }

        setState(() {
          reviews = updatedReviews; // 리뷰 리스트를 저장
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
    final majorId2 = loggedInUser?.major2;
    final majorId3 = loggedInUser?.major3;
    fetchMajorInfo(majorId, majorId2, majorId3);
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
        title: Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ProfileBody(
        nickname: loggedInUser?.nickname,
        name: loggedInUser?.name,
        studentId: loggedInUser?.student_id,
        major: major,
        major2: major2,
        major3: major3,
        introduction: loggedInUser?.introduction ?? '',
        reviews: reviews,
        averageRating: averageRating,
        profileIconCodePoint: loggedInUser?.user_image, // 아이콘 코드포인트 추가
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final String? nickname;
  final String? name;
  final int? studentId;
  final String? major;
  final String? major2;
  final String? major3;
  final String? introduction;
  final List<dynamic>? reviews;
  final double? averageRating;
  final int? profileIconCodePoint;

  ProfileBody({
    this.nickname,
    this.name,
    this.studentId,
    this.major,
    this.major2,
    this.major3,
    this.introduction,
    this.reviews,
    this.averageRating,
    this.profileIconCodePoint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 정보 표시
          GestureDetector(
            onTap: () {},
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
                    profileIconCodePoint != null
                        ? IconData(profileIconCodePoint!, fontFamily: 'MaterialIcons')
                        : Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        nickname ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xff19A7CE),
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: name ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' | ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: studentId != null ? studentId.toString() : '',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            major ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          if (major2 != null && major2!.isNotEmpty) ...[
                            Text(
                              ' | $major2',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                          if (major3 != null && major3!.isNotEmpty) ...[
                            Text(
                              ' | $major3',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            '   $introduction',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 30),
          Divider(height: 1, color: Color(0xff19A7CE)),
          SizedBox(height: 10),
          Text(
            '리뷰',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Divider(height: 1, color: Color(0xff19A7CE)),
          SizedBox(height: 20),
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
          if (reviews != null && reviews!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: Color(0xff19A7CE)),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reviews!.length,
                  itemBuilder: (context, index) {
                    final review = reviews![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey, // 임시로 회색으로 지정
                                ),
                                child: Icon(
                                  profileIconCodePoint != null
                                      ? IconData(profileIconCodePoint!, fontFamily: 'MaterialIcons')
                                      : Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['reviewer_nickname']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff19A7CE),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review['rating'] ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                          size: 18,
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 5),
                                    Text(review['content'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        review['update_at']?.toString().substring(0, 10) ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
