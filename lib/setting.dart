import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'resetpassword.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SharedPreferences _prefs;

  bool allowNotifications = true;
  bool chatroomNotification = true;
  bool qnaNotification = true;
  bool supportResultNotification = true;
  bool reviewNotification = true;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
  }

  Future<void> _loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        allowNotifications = _prefs.getBool('allowNotifications') ?? true;
        chatroomNotification = _prefs.getBool('chatroomNotification') ?? true;
        qnaNotification = _prefs.getBool('qnaNotification') ?? true;
        supportResultNotification = _prefs.getBool('supportResultNotification') ?? true;
        reviewNotification = _prefs.getBool('reviewNotification') ?? true;
      });
    } catch (error) {
      print('Error loading notification settings: $error');
    }
  }

  Future<void> _updateSettings() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/setnoti'),
        body: json.encode({
          'user_id': loggedInUser?.user_id,
          'all_noti': allowNotifications,
          'chatroom_noti': chatroomNotification,
          'qna_noti': qnaNotification,
          'accept_noti': supportResultNotification,
          'review_noti': reviewNotification,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Notification settings updated successfully');
        _prefs.setBool('allowNotifications', allowNotifications);
        _prefs.setBool('chatroomNotification', chatroomNotification);
        _prefs.setBool('qnaNotification', qnaNotification);
        _prefs.setBool('supportResultNotification', supportResultNotification);
        _prefs.setBool('reviewNotification', reviewNotification);
      } else {
        print('Failed to update notification settings');
      }
    } catch (error) {
      print('Error updating notification settings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.grey.shade200,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xff19A7CE),
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              '알림 허용',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            value: allowNotifications,
            onChanged: (value) {
              setState(() {
                allowNotifications = value;
                // 알림 허용이 변경되면 모든 세부 알림 설정도 함께 변경
                if (!value) {
                  // 알림 허용이 꺼진 경우, 모든 세부 알림 설정을 false로 변경
                  chatroomNotification = false;
                  qnaNotification = false;
                  supportResultNotification = false;
                  reviewNotification = false;
                }
              });
              _updateSettings(); // 알림 설정 업데이트 요청 보내기
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '세부 알림 설정',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Divider(),
          _buildNotificationSettingItem(
            '채팅방 알림 설정',
            chatroomNotification,
            allowNotifications,
                (value) {
              setState(() {
                chatroomNotification = value;
                _prefs.setBool('chatroomNotification', value);
              });
              _updateSettings();
            },
          ),
          _buildNotificationSettingItem(
            'Q&A 알림 설정',
            qnaNotification,
            allowNotifications,
                (value) {
              setState(() {
                qnaNotification = value;
                _prefs.setBool('qnaNotification', value);
              });
              _updateSettings();
            },
          ),
          _buildNotificationSettingItem(
            '지원 결과 알림 설정',
            supportResultNotification,
            allowNotifications,
                (value) {
              setState(() {
                supportResultNotification = value;
                _prefs.setBool('supportResultNotification', value);
              });
              _updateSettings();
            },
          ),
          _buildNotificationSettingItem(
            '리뷰 알림 설정',
            reviewNotification,
            allowNotifications,
                (value) {
              setState(() {
                reviewNotification = value;
                _prefs.setBool('reviewNotification', value);
              });
              _updateSettings();
            },
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.grey.shade200,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              '회원정보 변경',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xff19A7CE),
              ),
            ),
          ),
          ListTile(
            title: Text(
              '비밀번호 변경',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              // 비밀번호 변경 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage(email: loggedInUser?.email ?? '')), // Pass the email parameter here
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildNotificationSettingItem(
      String title,
      bool value,
      bool allowNotifications,
      ValueChanged<bool> onChanged,
      ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      trailing: allowNotifications
          ? Switch(
        value: value,
        onChanged: onChanged,
      )
          : Switch(
        value: value,
        onChanged: null, // 알림 허용이 꺼져있을 때 스위치를 눌러도 변화 없음
      ),
    );
  }
}
