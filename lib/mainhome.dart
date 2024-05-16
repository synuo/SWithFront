import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice/home.dart';
import 'package:practice/mypage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common_widgets.dart';
import 'package:practice/board.dart';
import 'package:practice/chat.dart';

class mainhomescreen extends StatefulWidget {
  const mainhomescreen({super.key});

  @override
  State<mainhomescreen> createState() => _mainhomescreenState();
}

class _mainhomescreenState extends State<mainhomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Main Home', style: TextStyle(color: Color(0xff19A7CE), fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          _buildNotificationButton(),
          _buildMenuButton(),
        ],
      ),
    )
  }
}
