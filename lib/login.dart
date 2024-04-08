import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:practice/findpw.dart';
import 'package:practice/newsignup2.dart';
import 'package:practice/signup.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In Page', style: TextStyle(color: Colors.white, fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Color(0xff19A7CE),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[IconButton(icon: Icon(Icons.help_outline_sharp), onPressed: () {})],
      ),
      body: GestureDetector(
        onTap: () {FocusScope.of(context).unfocus();},
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Center(child: Icon(Icons.cookie),),
              Form(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.white,
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Color(0xff19A7CE), fontSize: 15.0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(60.0),
                    child: Builder(
                      builder: (context) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextField(
                              controller: _emailController,
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: '숙명 이메일을 입력해주세요.',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: '비밀번호를 입력해주세요.',
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                            ),
                            SizedBox(height: 20.0),
                            ButtonTheme(
                              child: ElevatedButton(
                                onPressed: () async {
                                  print("로그인하기 버튼 클릭함");
                                  print(_emailController.text);
                                  print(_passwordController.text);
                                  await login(context);
                                },
                                child: Text('로그인하기', style: TextStyle(color: Colors.white, fontSize: 15.0),),
                                style: ElevatedButton.styleFrom(backgroundColor: Color(0xff19A7CE)),),
                            ),
                            SizedBox(height: 40.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => FindPassword()),
                                    );
                                    print('화면전환 : login -> findpw');
                                  },
                                  child: Text('비밀번호를 잊으셨나요?', style: TextStyle(color: Color(0xff19A7CE), decoration: TextDecoration.underline),),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignupPage()),
                                    );
                                    print('화면전환 : login -> signup');
                                  },
                                  child: Text('회원가입하기', style: TextStyle(color: Color(0xff19A7CE), decoration: TextDecoration.underline),),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future <void> login(BuildContext context) async {  //로그인 처리 함수
    print("login 함수 실행됨");
    final url = Uri.parse('http://localhost:3000/login');   // Uri.parse() : 서버의 주소를 파싱하여 Uri 객체를 생성
    print(url);
    final response = await http.post( //POST 요청을 보냄
      url, //첫 번째 인자는 요청을 보낼 URL임.
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({ //두 번째 인자는 요청 본문(body)
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );
    print(response.statusCode);
    //서버에서의 응답은 http.Response 객체로 받게 됨.
    //응답의 상태 코드(statusCode)를 확인하여 요청이 성공했는지 아니면 실패했는지를 판단
    if (response.statusCode == 200) { // 상태 코드가 200인 경우는 성공
      print('Logged in!');
      loginok();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공'),
            backgroundColor: Colors.green,
          ),
      );
      navigateToHomePage(context); // 로그인 성공 시 홈 페이지로 이동
    } else {
      print('Logged in failed..');
      print(response.statusCode);
      loginfail();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void navigateToHomePage(BuildContext context) {  // 홈 페이지로 이동
    print('화면전환 : homepage ');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  //fluttertoast 띄워주는 loginok, lohinfail (확인 용도)
  void loginok() {
    Fluttertoast.showToast(
      msg: '로그인 성공!',
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.lightBlueAccent,
      fontSize: 20,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }
  void loginfail() {
    Fluttertoast.showToast(
      msg: '로그인 실패..',
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.lightBlueAccent,
      fontSize: 20,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.  ScaffoldMessenger.of(context).showSnackBar(snackBar);
void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );
}
