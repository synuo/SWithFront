import 'package:mysql1/mysql1.dart';
import 'package:practice/main.dart';
import 'package:practice/newlogin.dart';
import 'package:practice/home.dart';

class UserInfo {
  String email;
  String name;
  String nickname;
  String password;
  String student_id;
  String major1;
  String major2;
  String major3;
  String introduction;
  String profileImage;

  UserInfo({
    required this.email,
    required this.name,
    required this.nickname,
    required this.password,
    required this.student_id,
    required this.major1,
    required this.major2,
    required this.major3,
    required this.introduction,
    required this.profileImage,
  });

  static Future<UserInfo?> getUserInfoByEmail(String email) async {
    final settings = ConnectionSettings(
      host: 'database-1.chaaga8wom43.us-east-2.rds.amazonaws.com',
      port: 3306,
      user: 'root',
      password: '12345678',
      db: 'SWith',
    );

    final connection = await MySqlConnection.connect(settings);

    try {
      final results = await connection.query(
        'SELECT email, name,  nickname, password, student_id, major1, major2, major3, profile_image, introduction '
            'FROM users WHERE email = ?', [email],
      );

      if (results.isNotEmpty) {
        final userInfoRow = results.first;
        return UserInfo(
          email: userInfoRow['email'],
          name: userInfoRow['name'],
          nickname: userInfoRow['nickname'],
          password: userInfoRow['password'],
          student_id : userInfoRow['student_id'],
          major1: userInfoRow['major1'],
          major2: userInfoRow['major2'],
          major3: userInfoRow['major3'],
          introduction: userInfoRow['introduction'],
          profileImage: userInfoRow['profile_image'],
        );
      } else {
        return null;
      }
    } finally {
      await connection.close();
    }
  }
}