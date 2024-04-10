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
  final TextEditingController _emailController = TextEditingController(); //이메일
  final TextEditingController _verificationCodeController = TextEditingController(); //인증코드
  late String _verificationCode;
  bool _codeSent = false;
  bool _emailExists = false; //이미 존재하는 이메일 db인지 확인 용도

  Future<MySqlConnection> _getConnection() async {
    final settings = ConnectionSettings(
      host: 'http://localhost:3000',
      port: 3306,
      user: 'your_mysql_username',
      password: 'your_mysql_password',
      db: 'your_database_name',
    );

    return await MySqlConnection.connect(settings);
  }

  //인증코드 생성해서 메일로 보냄
  Future<void> _sendVerificationCode(String email) async {
    print("인증코드 발송 함수 실행됨");
    final random = Random();
    _verificationCode = random.nextInt(999999).toString().padLeft(6, '0'); // 6자리 랜덤 숫자 생성

    // SMTP 서버 설정
    final smtpServer = gmail('swithsookmyung@gmail.com', 'zeud katx bkqz ahhj');

    // 이메일 제목 및 내용 설정
    final message = Message()
      ..from = Address('your_email@gmail.com')
      ..recipients.add(email) // 사용자가 입력한 이메일 주소로 설정
      ..subject = 'Verification Code'
      ..text = 'Your verification code is: $_verificationCode';

    // 이메일 보내기
    try {
      await send(message, smtpServer);
      print('Message sent successfully');
      setState(() {
        _codeSent = true; // 이메일이 성공적으로 보내졌을 때에만 _codeSent를 true로 설정
      });
    } catch (e) {
      print('Error occurred while sending email: $e');
    }

    //방식2
    /*
    _verificationCode = verificationCode; // 인증 코드를 저장
    final Email emailToSend = Email(
      body: '인증 코드: $verificationCode',
      subject: '회원가입 인증 코드',
      recipients: [_emailController.text],
      isHTML: false,  //이메일 본문이 HTML 형식인지 알려주는 bool값
    );
    try {
      await FlutterEmailSender.send(emailToSend);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('인증 코드를 이메일로 전송했습니다.')),);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 전송에 실패했습니다.')),);
    }
    _verifyCode();

     */

  }

  //인증코드 일치하는지 확인
  Future<void> _verifyCode() async {
    // 입력한 인증 코드
    final enteredCode = _verificationCodeController.text;  //입력받은 인증코드
    if (enteredCode == _verificationCode) { // 인증 코드 일치
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserInfoPage()),
      );
    } else {
      // 인증 코드 불일치
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('잘못된 인증 코드입니다. 다시 시도해주세요.')));
      _verificationCodeController.clear();  // 인증 코드 입력 필드 초기화
    }
  }

  // 이메일 중복 여부를 확인
  Future<void> _checkEmailExists(String email) async {
    print('이메일 중복 확인 함수 실행됨.');
    //서버에 이메일 확인
    final conn = await _getConnection();
    var result = await conn.query(
        'SELECT COUNT(*) as count FROM users WHERE email = ?', [email]);
    await conn.close();

    setState(() {
      _emailExists = result.first['count'] > 0;
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
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  if (email.endsWith('@sookmyung.ac.kr')) {
                    await _checkEmailExists(email);
                    if (!_emailExists) {   //새로운 이메일 주소면 인증코드 전송
                      await _sendVerificationCode(email);
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
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      labelText: '인증 코드',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      String enteredCode = _verificationCodeController.text.trim();
                      if (enteredCode == _verificationCode) { // 인증코드 올바르면
                        print("성공");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserInfoPage(),),
                        ); //회원 정보 입력 화면으로 이동
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('잘못된 인증 코드입니다.'),
                        ));
                      }
                    },
                    child: Text('확인'),
                  ),
                  SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _codeSent = false;
                        _verificationCodeController.clear();
                      });
                    },
                    child: Text('새로운 인증 코드 받기'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

}
