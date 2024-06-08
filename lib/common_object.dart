import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const List<IconData> profileIcons = [
  Icons.person,
  Icons.cookie,
  Icons.ac_unit,
];

class Post {
  final int post_id;
  final int writer_id;
  final String? writer_image;
  final String? writer_nickname;
  final String? writer_student_id;
  final String? writer_major1;
  final String? writer_major2;
  final String? writer_major3;
  final DateTime create_at;
  final DateTime update_at;
  final String title;
  final String category;
  final String study_name;
  final String content;
  final String progress;
  final int view_count;

  Post({
    required this.post_id,
    required this.writer_id,
    required this.create_at,
    this.writer_image,
    this.writer_nickname,
    this.writer_student_id,
    this.writer_major1,
    this.writer_major2,
    this.writer_major3,
    required this.update_at,
    required this.title,
    required this.category,
    required this.study_name,
    required this.content,
    required this.progress,
    required this.view_count,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      post_id: json['post_id'],
      writer_id: json['writer_id'],
      create_at: DateTime.parse(json['create_at']),
      update_at: DateTime.parse(json['update_at']),
      title: json['title'],
      category: json['category'],
      study_name: json['study_name'],
      content: json['content'],
      progress: json['progress'],
      view_count: json['view_count'],
    );
  }
}

class User {
  final int user_id;
  final String email;
  final String password;
  final String name;
  final int student_id;
  final String nickname;
  final int? user_image; // Nullable
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
      user_image: json['user_image'] != null ? int.tryParse(json['user_image']) : null, // 문자열을 int로 변환
      major1: json['major1'],
      major2: json['major2'],
      major3: json['major3'],
      major1_change_log: json['major1_change_log'],
      introduction: json['introduction'],
      all_noti: json['all_noti'],
      chatroom_noti: json['chatroom_noti'],
      qna_noti: json['qna_noti'],
      accept_noti: json['accept_noti'],
      review_noti: json['review_noti'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'email': email,
      'password': password,
      'name': name,
      'student_id': student_id,
      'nickname': nickname,
      'user_image': user_image?.toString(), // int를 문자열로 변환
      'major1': major1,
      'major2': major2,
      'major3': major3,
      'major1_change_log': major1_change_log,
      'introduction': introduction,
      'all_noti': all_noti,
      'chatroom_noti': chatroom_noti,
      'qna_noti': qna_noti,
      'accept_noti': accept_noti,
      'review_noti': review_noti,
    };
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

  void updateUser(User user) {
    _loggedInUser = user;
    notifyListeners();
  }
}

