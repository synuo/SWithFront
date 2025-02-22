import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

//05.20 수정본 수정본
void main() {
  HttpOverrides.global = new ProxiedHttpOverrides("1.209.144.251:3000");
  runApp(
      //const MyApp()
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MyApp(),
      ),
  );

}

class MyApp extends StatelessWidget {  //앱의 메인페이지 MyApp
  static Size? screenSize; // 전역으로 사용할 화면 크기를 저장하는 변수 선언
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 통해 현재 화면의 크기를 가져옴
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home : const HomePage(),
      title: 'SWith',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(  //앱의 기본 컬러 테마
            primary: Color(0xff19A7CE),
            secondary: Colors.lightBlueAccent,
            background: Colors.white54,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity, //플랫폼 간 레이아웃 일관성 유지
        fontFamily: 'San Francisco', // San Francisco 폰트 사용
      ),
      home: SplashScreen(),  //시작 : 스플래시
    );
  }
}

//스플래시화면
class SplashScreen extends StatefulWidget {
  //const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 2), navigateToLoginPage);
  }

  void navigateToLoginPage(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogInPage()), // 로그인 페이지로 이동
    );
    print('화면전환 : splash -> login');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox(height: 20), // 아이콘과 텍스트 사이의 간격 조정
            Text(
              'SWith',
              style: TextStyle(
                fontSize: 70, fontFamily: 'Teko',
                color: Theme.of(context).colorScheme.primary, // MyApp의 테마 색상 사용
                  shadows: [
                    Shadow(
                      offset: Offset(1.0,1.0),
                      blurRadius: 5.0,
                      color: Color.fromARGB(80, 0, 0, 0),
                    )
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProxiedHttpOverrides extends HttpOverrides{
  String _proxy;
  ProxiedHttpOverrides(this. _proxy);

  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
        ..findProxy = (uri){
      return _proxy.isNotEmpty ? "PROXY $_proxy;" : 'DIRECT';
    }
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => Platform.isAndroid;
  }

}


