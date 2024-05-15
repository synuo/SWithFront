import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      allowNotifications = _prefs.getBool('allowNotifications') ?? true;
      chatroomNotification = _prefs.getBool('chatroomNotification') ?? true;
      qnaNotification = _prefs.getBool('qnaNotification') ?? true;
      supportResultNotification = _prefs.getBool('supportResultNotification') ?? true;
      reviewNotification = _prefs.getBool('reviewNotification') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.grey.shade200,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          SwitchListTile(
            title: Text('알림 허용'),
            value: allowNotifications,
            onChanged: (value) {
              setState(() {
                allowNotifications = value;
                _prefs.setBool('allowNotifications', value);
                // 알림 허용이 변경되면 모든 세부 알림 설정도 함께 변경
                if (!value) {
                  // 알림 허용이 꺼진 경우, 모든 세부 알림 설정을 false로 변경
                  chatroomNotification = false;
                  qnaNotification = false;
                  supportResultNotification = false;
                  reviewNotification = false;
                  _prefs.setBool('chatroomNotification', false);
                  _prefs.setBool('qnaNotification', false);
                  _prefs.setBool('supportResultNotification', false);
                  _prefs.setBool('reviewNotification', false);
                } else {
                  // 알림 허용이 켜진 경우, 모든 세부 알림 설정을 알림 허용과 동일하게 변경
                  chatroomNotification = value;
                  qnaNotification = value;
                  supportResultNotification = value;
                  reviewNotification = value;
                  _prefs.setBool('chatroomNotification', value);
                  _prefs.setBool('qnaNotification', value);
                  _prefs.setBool('supportResultNotification', value);
                  _prefs.setBool('reviewNotification', value);
                }
              });
              // 업데이트 함수 호출
              updateNotificationSettings();
            },
          ),
          Divider(),
          Text('    세부 알림 설정'),
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
              updateNotificationSettings();
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
              updateNotificationSettings();
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
              updateNotificationSettings();
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
              updateNotificationSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingItem(
      String title, bool value, bool allowNotifications, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: allowNotifications
          ? CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      )
          : CupertinoSwitch(
        value: value,
        onChanged: null, // 알림 허용이 꺼져있을 때 스위치를 눌러도 변화 없음
      ),
    );
  }

  Future<void> updateNotificationSettings() async {
    // 업데이트 함수의 내용은 그대로 유지됩니다.
  }
}
