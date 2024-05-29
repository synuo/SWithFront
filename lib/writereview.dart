import 'package:flutter/material.dart';

class WriteReviewScreen extends StatelessWidget {
  final int userId;

  WriteReviewScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Write a review for user ID: $userId'),
            // 리뷰 작성 폼 추가
            TextField(
              decoration: InputDecoration(
                labelText: 'Review',
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 리뷰 저장 로직 추가
                Navigator.pop(context);
              },
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
