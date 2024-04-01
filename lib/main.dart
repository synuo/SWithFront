import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart';

void main() {runApp(const MyApp());}

class MyApp extends StatelessWidget {  //앱의 메인페이지 MyApp
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
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
        fontFamily: 'SF Pro Display', // San Francisco 폰트 사용
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
      MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
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
            Icon(Icons.cookie),  //TODO : Image.asset('assets/image/potato.png') 해결
            SizedBox(height: 20), // 아이콘과 텍스트 사이의 간격 조정
            Text(
              'SWith',
              style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary, // MyApp의 테마 색상 사용
              ),),],
        ),
      ),
    );
  }
}


