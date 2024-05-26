import 'package:flutter/cupertino.dart';

class Post {
  final int post_id;
  final int writer_id;
  final DateTime create_at;
  final DateTime update_at;
  final String title;
  final String category;
  final String study_name;
  final String content;
  final String progress;
  final int view_count;

  Post(
      {required this.post_id,
        required this.writer_id,
        required this.create_at,
        required this.update_at,
        required this.title,
        required this.category,
        required this.study_name,
        required this.content,
        required this.progress,
        required this.view_count,
        });
}

class User{
  final int user_id;
  final String email;
  final String password;
  final String name;
  final int student_id;
  final String nickname;
  final String? user_image;   // ? : Nullable
  final int major1;
  final int? major2;
  final int? major3;
  final int major1_change_log;
  final String? introduction;
  final int all_noti;
  final int chatroom_noti;
  final int qna_noti;
  final int accept_noti;
  final int review_noti;

  User({
    required this.user_id,
    required this.email,
    required this.password,
    required this.name,
    required this.student_id,
    required this.nickname,
    this.user_image,
    required this.major1,
    this.major2,
    this.major3,
    required this.major1_change_log,
    this.introduction,
    required this.all_noti,
    required this.chatroom_noti,
    required this.qna_noti,
    required this.accept_noti,
    required this.review_noti,
  });

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
      user_id: json['user_id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      student_id: json['student_id'],
      nickname: json['nickname'],
      user_image: json['user_image'],
      major1: json['major1'],
      major2: json['major2'],
      major3: json['major3'],
      major1_change_log: json['major1_change_log'] ,
      introduction: json['introduction'],
      all_noti: json['all_noti'],
      chatroom_noti: json['chatroom_noti'],
      qna_noti: json['qna_noti'],
      accept_noti: json['accept_noti'],
      review_noti: json['review_noti'],
    );
  }
}

class UserProvider with ChangeNotifier {
  User? _loggedInUser;

  User? get loggedInUser => _loggedInUser;

  void setLoggedInUser(User user) {
    _loggedInUser = user;
    notifyListeners();
  }

  void clearUser() {
    _loggedInUser = null;
    notifyListeners();
  }
}