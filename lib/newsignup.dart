import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:practice/userinfo.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class newSignupPage2 extends StatefulWidget {
  const newSignupPage2({Key? key}) : super(key: key);
  @override
  State<newSignupPage2> createState() => _newSignupPageState2();
}

class _newSignupPageState2 extends State<newSignupPage2> {
  final TextEditingController _emailController = TextEditingController(); //이메일 입력받음
  final TextEditingController _verificationCodeController = TextEditingController(); //인증코드 입력받음
  late String _email;             //사용자 이메일
  late String _verificationCode;  //인증코드
  late String _enteredCode;      //사용자가 입력한 코드
  bool _codeSent = false;    // 인증코드 전송 여부
  bool _emailExists = false; //이미 존재하는 이메일 db인지 확인 용도
  bool _codesendagain = false;
  late String sessionId; // 세션 ID를 저장하는 변수
  late String expectedCode;
  //인증코드 생성해서 메일로 보냄
  Future<void> _sendVerificationCode(String email) async {
    print("인증 코드 발송 함수 실행됨");

    final url = Uri.parse('http://localhost:3000/email/sendVerificationCode');   // Uri.parse() : 서버의 주소를 파싱하여 Uri 객체를 생성
    print(url);
    final response = await http.post( //POST 요청을 보냄
      url, //첫 번째 인자는 요청을 보낼 URL임.
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({ //두 번째 인자는 요청 본문(body)
        'email': email,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('인증 코드 전송 완료!');
      expectedCode = jsonDecode(response.body)['code'];
      setState(() {
        _codeSent = true; // 이메일이 성공적으로 보내졌을 때에만 _codeSent를 true로 설정
      });
    } else {
      print('인증 코드 전송 실패..');
    }
  }

  //인증코드 일치하는지 확인  + 인증 코드 재발송.입력?
  Future<void> _verifyCode(String enterCode) async {
    // 입력한 인증 코드
    print(enterCode);
    final url = Uri.parse('http://localhost:3000/email/verifyCode');   // Uri.parse() : 서버의 주소를 파싱하여 Uri 객체를 생성
    print(url);
    final response = await http.post( //POST 요청을 보냄
      url, //첫 번째 인자는 요청을 보낼 URL임.
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',

      },
      body: jsonEncode({ //두 번째 인자는 요청 본문(body)
        'codeFromUser': enterCode,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('올바른 인증 코드!');
      setState(() {
        _codeSent = true; // 이메일이 성공적으로 보내졌을 때에만 _codeSent를 true로 설정
      });
    } else {
      print('잘못된 인증 코드..');
      _verificationCodeController.clear();  //입력 초기화
    }

  }

  // 이메일 중복 여부를 확인
  Future<void> _checkEmailExists(String email) async {
    print('이메일 중복 확인 함수 실행됨.');

    // 이메일 존재 여부를 나타내는 변수 초기화
    bool emailExists = false;

    try {
      // 로컬 호스트의 checkemail.js에 HTTP GET 요청 보내기
      var response = await http.get(Uri.parse('http://localhost:3000/checkemail?email=$email'));

      // 요청이 성공하면 응답 본문을 JSON으로 파싱하여 데이터 추출
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // 데이터베이스에서 이메일 존재 여부 확인 후 emailExists 변수 업데이트
        emailExists = data['exists'];
      } else {
        // HTTP 요청이 실패한 경우 오류 메시지 출력
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // 오류가 발생한 경우 오류 메시지 출력
      print('Error: $e');
    }
    // 결과를 _emailExists 변수에 저장
    _emailExists = emailExists;


  }

  Future<void> _resendVerificationCode() async {
    setState(() {
      _codeSent = false;
    });
    _verificationCodeController.clear();
    await _sendVerificationCode(_email);
    setState(() {
      _codeSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '회원가입', style: TextStyle(color: Colors.white, fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Color(0xff19A7CE),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              //TODO
            }
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                //TODO
              }
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '숙명 이메일 @sookmyung.ac.kr 을 입력해주세요.',
              ),
            ),
            SizedBox(height: 20.0),
            if (!_codeSent)
              //이메일 입력 & 중복 확인 , 인증코드 발송(발송 성공하면 _codeSent true)
              ElevatedButton(
                onPressed: () async {
                  _email = _emailController.text.trim();
                  print(_email);
                  if (_email.endsWith('@sookmyung.ac.kr')) {    //숙명 이메일이라면
                    //await _checkEmailExists(_email);
                    if (!_emailExists) {   //새로운 이메일 주소면 인증코드 전송
                      await _sendVerificationCode(_email);
                      setState(() {
                        _codeSent = true;   //성공했다 가정(나중에 삭제)
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(  //이미 존재하는 이메일인 경우
                          SnackBar(content: Text('이미 등록된 이메일 주소입니다.'),));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('@sookmyung.ac.kr 이메일 주소를 입력해주세요.'),
                        ));
                  }
                },
                child: Text('인증 코드 발송'),
              ),
            SizedBox(height: 20.0),
            if (_codeSent)
              //인증코드 입력 & 맞는지 확인. 틀리면 재입력 가능. 인증코드 재발송 가능.
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(labelText: '인증 코드 6자리를 입력하세요.',),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _enteredCode = _verificationCodeController.text.trim();
                          //_verifyCode(_enteredCode);
                          if(expectedCode == _enteredCode) {
                            print("성공!");
                          }
                          else print("실패...");
                        },
                        child: Text('확인'),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed:(){ _resendVerificationCode();},
                        child: Text('새로운 인증 코드 받기'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

}
