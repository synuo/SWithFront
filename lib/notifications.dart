import 'package:flutter/material.dart';
import 'board.dart';
import 'chat.dart';
import 'newhome.dart';
import 'main.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
      ),
      body: Center(
        child: Text('여기는 알림 화면입니다.'),
      ),
    );
  }
}
