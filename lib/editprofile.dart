import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice/mypage.dart';
import 'package:practice/notifications.dart';
import 'package:practice/post_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'board.dart';
import 'chat.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
