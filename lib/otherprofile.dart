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
  String? major, major2, major3;
  Map<String, dynamic>? userData;
  bool canWriteReview = true;
  double averageRating = 0.0; // Default value
  List<dynamic> reviews = []; // Default value

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/user/${widget.senderId}'));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        userData = Map<String, dynamic>.from(decodedData);
        await fetchMajorInfo();
        await checkReviewStatus();
        await fetchReviews();
        return userData!;
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return {};
    }
  }

  Future<void> fetchMajorInfo() async {
    try {
      final response1 = await http.get(Uri.parse('http://localhost:3000/majorDetail/${userData!['major1']}'));
      if (response1.statusCode == 200) {
        final data = json.decode(response1.body);
        setState(() {
          major = data['major_name'];
        });
      } else {
        throw Exception('Failed to load major1 information');
      }

      final response2 = await http.get(Uri.parse('http://localhost:3000/majorDetail/${userData!['major2']}'));
      if (response2.statusCode == 200) {
        final data = json.decode(response2.body);
        setState(() {
          major2 = data['major_name'];
        });
      } else {
        throw Exception('Failed to load major2 information');
      }

      final response3 = await http.get(Uri.parse('http://localhost:3000/majorDetail/${userData!['major3']}'));
      if (response3.statusCode == 200) {
        final data = json.decode(response3.body);
        setState(() {
          major3 = data['major_name'];
        });
      } else {
        throw Exception('Failed to load major3 information');
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
        final data = json.decode(response.body);
        return data['nickname'];
      } else {
        throw Exception('Failed to load user information');
      }
    } catch (error) {
      print('Error fetching user information: $error');
      return 'Unknown';
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
        title: Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileBody(
                          nickname: userData['nickname'] ?? '',
                          major: major ?? '',
                          major2: major2 ?? '',
                          major3: major3 ?? '',
                          introduction: userData['introduction'] ?? '',
                          reviews: reviews,
                          averageRating: averageRating,
                          isOtherProfile: true, // Pass this parameter
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              minimumSize: Size(200, 50),
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
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
