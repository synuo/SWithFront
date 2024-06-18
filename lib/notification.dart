import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;  //주기적인 알림
import 'package:timezone/timezone.dart' as tz;

final notifications = FlutterLocalNotificationsPlugin();

//앱 로드 시 실행할 기본 설정
initNotification(context) async{

  //안드로이드용 아이콘 파일 이름
  var androidSetting = AndroidInitializationSettings('app_icon');

  //ios에서 앱 로드시 유저에게 권한 요청하려면
  var iosSetting = IOSInitializationSettings(
    requestAlertPermission : true,
    requestBadgePermission : true,
    requestSoundPermission : true,
  );

  var initializationSettings = InitializationSettings(
    android : androidSetting,
    iOS : iosSetting
  );

  await notifications.initialize(
    initializationSettings,
    //알림 누를 때 함수 실행하고 싶으면
    //onSelectNotification : 함수명 추가
    onSelectNotification: (payload){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Text('새로운 페이지'),
        )
      );
    }
  );
}

// 이 함수를 원하는 곳에서 실행하면 알림이 뜸
showNotification() async{
  var androidDetails = AndroidNotificationDetails(
    'channelId',   //알림 채널 ID
    'channelName',  //알림 종류 설명
    priority: Priority.high,   //알림 소리
    importance: Importance.max,   //알림 팝업
    color: Color.fromARGB(255, 255, 0, 0),  //알림 색상

  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,  //알림 여부
    presentBadge: true,  //뱃지 여부
    presentSound: true,  //알림 보여줄 때 소리
  );

  //알림 id, 제목, 내용
  notifications.show(
    1,
    '제목1',
    '내용1',
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    payload: '부가정보'
  );

}

// 이 함수를 원하는 곳에서 실행하면 알림이 뜸
showNotification2() async{
  tz.initializeTimeZones();

  var androidDetails = AndroidNotificationDetails(
    'channelId',   //알림 채널 ID
    'channelName',  //알림 종류 설명
    priority: Priority.high,   //알림 소리
    importance: Importance.max,   //알림 팝업
    color: Color.fromARGB(255, 255, 0, 0),  //알림 색상

  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,  //알림 여부
    presentBadge: true,  //뱃지 여부
    presentSound: true,  //알림 보여줄 때 소리
  );

  // 특정 시간 알림
  notifications.zonedSchedule(
      2,
      '제목2',
      '내용2',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
  );

  //주기적 알림
  notifications.periodicallyShow(
      3,
    '제목3',
    '내용3',
    RepeatInterval.daily,  //코드가 실행되는 시점으로부터 정확히 24시간 후 알림 뜸
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    androidAllowWhileIdle: true
  );

  //예정된 모든 알림 취소 : await notifications.cancel(id)
  //예정된 모든 알림 삭제 : await notifications.cancelAll();

}