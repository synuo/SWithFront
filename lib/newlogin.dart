import 'package:flutter/material.dart';
import 'package:practice/main.dart';
import 'package:practice/home.dart';
import 'package:http/http.dart' as http;
import 'package:practice/signup.dart';
import 'dart:convert';
import 'dart:async';
import 'findpw.dart';

class LogInPage2 extends StatefulWidget {
  const LogInPage2({Key? key}) : super(key: key);
  @override
  State<LogInPage2> createState() => _LoginPageState2();
}

class _LoginPageState2 extends State<LogInPage2> {

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        body: Center(
            child: isSmallScreen ? Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _Logo(),
                _FormContent(),
              ],
            ) : Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: const [
                  Expanded(child: _Logo()),
                  Expanded(
                    child: Center(child: _FormContent()),
                  ),
                ],
              ),
            )));

  }
}

//로고
class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlutterLogo(size: isSmallScreen ? 100 : 200),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to SWith!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: Colors.black),
          ),
        )
      ],
    );
  }
}

//로그인 위젯
class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              validator: (value) {
                // add email validation
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요.';
                }
                bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@sookmyung\.ac\.kr$")
                    .hasMatch(value);
                if (!emailValid) {
                  return '숙명 메일 @sookmyung.ac.kr를 입력해주세요.';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: '숙명 메일을 입력해주세요.',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요.';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
            ),
            _gap(),
            CheckboxListTile(   //자동로그인
              value: _rememberMe,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _rememberMe = value;
                });
              },
              title: const Text('자동로그인하기'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Log in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    print("로그인하기 버튼 클릭함");
                    print(_emailController.text);
                    print(_passwordController.text);
                    await login(context);
                  }
                },
              ),
            ),
            _gap(),
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
                  child: Text('비밀번호 찾기', style: TextStyle(decoration: TextDecoration.underline),),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                    print('화면전환 : login -> signup');
                  },
                  child: Text('회원가입', style: TextStyle(decoration: TextDecoration.underline),),
                ),
              ],
            ),

          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 성공'),
          backgroundColor: Colors.green,
        ),
      );
      print('화면전환 : homepage ');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      ); // 로그인 성공 시 홈 페이지로 이동
    } else {
      print('Logged in failed..');
      print(response.statusCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _gap() => const SizedBox(height: 16);
}
