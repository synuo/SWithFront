import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/otherprofile.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WriteReviewScreen extends StatefulWidget {
  final int userId;

  WriteReviewScreen({required this.userId});

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  late Future<Map<String, dynamic>> _userFuture;
  late Map<String, dynamic> userData;
  late TextEditingController _reviewController;
  double _rating = 1.0; // Default rating

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/user/${widget.userId}'));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      userData = Map<String, dynamic>.from(decodedData);
      return userData;
    } else {
      print('Failed to load user data: ${response.statusCode}');
      return {};
    }
  }

  Future<void> _submitReview() async {
    final revieweeId = widget.userId;
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final reviewerId = loggedInUser?.user_id;
    final content = _reviewController.text;

    final url = Uri.parse('http://localhost:3000/addreview');
    final response = await http.post(
      url,
      body: jsonEncode({
        'reviewee_id': revieweeId,
        'reviewer_id': reviewerId,
        'rating': _rating,
        'content': content,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Review added successfully.');
      Navigator.pop;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(senderId: widget.userId)
        ),
      );
    } else {
      print('Failed to add review: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 작성'),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('${userData['nickname']} 님은'),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      labelText: '리뷰',
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _submitReview,
                    child: Text('작성 완료'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
