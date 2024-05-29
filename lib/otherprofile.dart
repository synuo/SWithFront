import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String nickname;

  UserProfileScreen({required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              // 여기에 프로필 이미지 URL을 설정할 수 있습니다.
              // 이미지가 없는 경우 기본 이미지를 사용하거나 빈 상태로 유지할 수 있습니다.
              backgroundImage: AssetImage('assets/default_profile_image.png'),
            ),
            SizedBox(height: 20),
            Text(
              'Nickname: $nickname',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // 여기에 사용자의 다른 정보를 표시할 수 있습니다.
          ],
        ),
      ),
    );
  }
}
