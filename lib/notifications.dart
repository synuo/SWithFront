import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common_object.dart';
import 'mypage.dart';
import 'post_detail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;  //주기적인 알림
import 'package:timezone/timezone.dart' as tz;

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late SharedPreferences _prefs; // SharedPreferences 인스턴스
  List<Map<String, dynamic>> notifications = []; // 알림 목록
  bool allowNotifications = true; // 전체 알림 설정
  bool qnaNotification = true; // Q&A 알림 설정
  bool supportResultNotification = true; // 지원 결과 알림 설정
  bool reviewNotification = true; // 리뷰 알림 설정

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 알림 설정 로드
    _fetchNotifications(); // 알림 목록 로드
    _initializeLocalNotifications();
  }

  // SharedPreferences에서 알림 설정 로드
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      allowNotifications = _prefs.getBool('allowNotifications') ?? true;
      qnaNotification = _prefs.getBool('qnaNotification') ?? true;
      supportResultNotification = _prefs.getBool('supportResultNotification') ?? true;
      reviewNotification = _prefs.getBool('reviewNotification') ?? true;
    });
    print('allowNotifications : $allowNotifications');
    print('qnaNotification : $qnaNotification');
    print('supportResultNotification : $supportResultNotification');
    print('reviewNotification : $reviewNotification');
  }

  // 서버에서 알림 목록을 가져오는 메서드
  Future<void> _fetchNotifications() async {
    try {
      final userId = await _getUserId(); // 사용자 ID 로드
      print('User ID: $userId'); // 디버그 로그
      final response = await http.get(
        Uri.parse('http://localhost:3000/getnoti?user_id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // 디버그 로그
      print('Response body: ${response.body}'); // 디버그 로그

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notifications = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      print('Error: $error'); // 에러 로그
      throw Exception('Failed to load notifications');
    }
  }

  // 사용자 ID를 가져오는 메서드
  Future<int> _getUserId() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    print('Fetched User ID from SharedPreferences: $userId'); // 디버그 로그 추가
    return userId ?? 0;
  }

  // 알림을 읽은 상태로 표시하는 메서드
  Future<void> _markAsRead(int userId, int notiId) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/readnoti'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_id': userId, 'noti_id': notiId}),
      );

      if (response.statusCode == 201) {
        print('Notification marked as read successfully');
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // 알림을 삭제하는 메서드
  Future<void> _deleteNotification(int userId, int notiId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/deletenoti'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_id': userId, 'noti_id': notiId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.removeWhere((noti) => noti['noti_id'] == notiId);
        });
        print('Notification deleted successfully');
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    var androidSetting = AndroidInitializationSettings('app_icon');
    var iosSetting = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Text('새로운 페이지'),
          ),
        );
      },
    );
  }

  Future<void> _showNotification(int id, String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 0, 0),
    );

    var iosDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: '부가정보',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator()) // 알림이 없을 때 로딩 표시
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final userId = notification['user_id'];
          final notiId = notification['noti_id'];
          final notiType = notification['type'];
          final message = _generateNotificationMessage(notiType, notification);

          // 알림 설정에 따른 필터링
          if (!allowNotifications) {
            return Container();
          }
          if (notiType == 'qna' && !qnaNotification) {
            return Container();
          }
          if (notiType == 'support_result' && !supportResultNotification) {
            return Container();
          }
          if (notiType == 'review' && !reviewNotification) {
            return Container();
          }

          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text(notification['message']),
            onTap: () {
              _handleNotificationTap(notification); // 알림 클릭 시 처리
              _markAsRead(userId, notiId); // 알림을 읽은 상태로 표시
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteNotification(userId, notiId); // 알림 삭제
              },
            ),
          );
        },
      ),
    );
  }

  String _generateNotificationMessage(String type, Map<String, dynamic> notification) {
    switch (type) {
      case 'application':
        return '${notification['username']}님이 ${notification['post_title']} 모집글에 지원했습니다.';
      case 'acceptance':
        return '축하합니다 ${notification['username']}님! ${notification['study_title']} 스터디원으로 합격하셨습니다.';
      case 'review':
        return '${notification['username']}님에게 새로운 리뷰가 달렸습니다.';
      case 'qna':
        return '${notification['username']}님, 새로운 qna 알림이 있습니다.';
      default:
        return '새로운 알림이 도착했습니다.';
    }
  }

  // 알림 클릭 시 처리하는 메서드
  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (notification['type'] == 'post') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(post_id: notification['post_id']),
        ),
      );
    }
    if (notification['type'] == 'qna'){
      //TODO : qna가 달린 해당 게시물로 이동 or qna 전용 화면(만들어야되나?)으로 이동
    }
    if (notification['type'] == 'support_result'){
      //TODO : qna가 달린 해당 게시물로 이동 or qna 전용 화면(만들어야되나?)으로 이동
    }
    if (notification['type'] == 'review'){
      //TODO : 상세 리뷰 하나만 보여주기?
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPage(),
        ),
      );
    }
  }
}
