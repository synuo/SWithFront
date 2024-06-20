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

  Future<void> fetchMajorInfo(int? majorId, int? majorId2, int? majorId3) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          major = data['major_name'];
        });
      } else {
        throw Exception('Failed to load major information');
      }

      final response2 = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId2'));
      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        setState(() {
          major2 = data2['major_name'];
        });
      } else {
        throw Exception('Failed to load major2 information');
      }

      final response3 = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId3'));
      if (response3.statusCode == 200) {
        final data3 = json.decode(response3.body);
        setState(() {
          major3 = data3['major_name'];
        });
      } else {
        throw Exception('Failed to load major3 information');
      }
    } catch (error) {
      print('Error fetching major information: $error');
    }
  }

  Future<Map<String, dynamic>> fetchReviewerDetails(int reviewerId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/user/$reviewerId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'nickname': data['nickname'],
          'iconCodePoint': int.tryParse(data['user_image'].toString()) // Convert to int
        };
      } else {
        throw Exception('Failed to load user information');
      }
    } catch (error) {
      print('Error fetching user information: $error');
      return {'nickname': 'Unknown', 'iconCodePoint': null};
    }
  }

  Future<void> fetchReviews() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    final url = 'http://localhost:3000/getreview/user/$userId/reviews';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> updatedReviews = [];

        for (var review in data) {
          Map<String, dynamic> reviewerDetails = await fetchReviewerDetails(review['reviewer_id']);
          review['reviewer_nickname'] = reviewerDetails['nickname'];
          review['reviewer_icon_code_point'] = reviewerDetails['iconCodePoint'];
          updatedReviews.add(review);
        }

        setState(() {
          reviews = updatedReviews;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ProfileBody(
            nickname: loggedInUser?.nickname,
            name: loggedInUser?.name,
            studentId: loggedInUser?.student_id,
            major: major,
            major2: major2,
            major3: major3,
            introduction: loggedInUser?.introduction ?? '',
            reviews: reviews,
            averageRating: averageRating,
            profileIconCodePoint: loggedInUser?.user_image,
          ),
        ),
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
  final bool isOtherProfile; // Add this boolean

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
    this.isOtherProfile = false, // Initialize it with a default value
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: Colors.grey,
                    ),
                    child: Icon(
                      profileIconCodePoint != null
                          ? IconData(profileIconCodePoint!, fontFamily: 'MaterialIcons')
                          : Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20), // Adjusted width for spacing
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
                        if (!isOtherProfile && name != null && studentId != null) // Condition to hide " | "
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
                        if (isOtherProfile || name == null || studentId == null) // Condition to hide " | "
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
                                  text: studentId != null ? ' ${studentId.toString()}' : '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 10),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 10, // Adjust spacing between majors
                          children: [
                            if (major != null && major!.isNotEmpty) ...[
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3), // Adjust maxWidth based on available space
                                child: Text(
                                  major!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            if (major2 != null && major2!.isNotEmpty) ...[
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3), // Adjust maxWidth based on available space
                                child: Text(
                                  '|  $major2',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            if (major3 != null && major3!.isNotEmpty) ...[
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3), // Adjust maxWidth based on available space
                                child: Text(
                                  '|  $major3',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
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
            SizedBox(height: 20), // Adjusted height for spacing
            Text(
              introduction ?? '',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30), // Adjusted height for spacing
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
                  Expanded( // Ensures the stars and average text fit within the available space
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                  ),
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
                  ListView.separated( // Use ListView.separated for better handling of list items
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reviews!.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
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
                                    color: Colors.grey[200],
                                  ),
                                  child: Icon(
                                    review['reviewer_icon_code_point'] != null
                                        ? IconData(review['reviewer_icon_code_point'], fontFamily: 'MaterialIcons')
                                        : Icons.person,
                                    size: 40,
                                    color: Color(0xff19A7CE),
                                  ),
                                ),
                                SizedBox(width: 20), // Adjusted width for spacing
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
                                      Text(
                                        review['content'] ?? '',
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
      ),
    );
  }
}
