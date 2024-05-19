import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/userinfo.dart';
import 'dart:convert';
import 'dart:async';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

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

//회원가입 위젯 : 이메일 중복확인 + 인증코드 입력
class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController(); //이메일 입력받음
  final TextEditingController _verificationCodeController = TextEditingController(); //인증코드 입력받음
  late String _email;             //사용자 이메일
  late String _enteredCode;      //사용자가 입력한 코드
  bool emailValid = false;
  bool _codeSent = false;    // 인증코드 전송 여부
  bool _emailExists = false; //이미 존재하는 이메일 db인지 확인 용도
  //late String sessionId; // 세션 ID를 저장하는 변수
  late String expectedCode;  //인증코드를 저장하는 변수

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
                emailValid = RegExp(
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
                    '이메일 확인하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    print("이메일 확인 버튼 클릭함");
                    print(_emailController.text);
                    await _checkEmailExists(_emailController.text);
                  }
                  if(emailValid && !_emailExists){
                    _email = _emailController.text;
                    await _sendVerificationCode(_email);
                  }
                },
              ),
            ),
            _gap(),
            if (_codeSent) ...[
              Text(
                '인증 코드 6자리가 메일로 전송되었습니다.',
                style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.normal),
              ),
              TextFormField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '인증코드 6자리를 입력해주세요.',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              _gap(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      print("확인 버튼 클릭함");
                      _enteredCode = _verificationCodeController.text.trim();
                      if(expectedCode == _enteredCode) {
                        print("인증코드 확인 완료!");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('인증코드 확인 완료!'),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => UserInfoPage(email: _email)),
                        );
                        print('화면전환 : emailcheck -> userinfo');
                      } else {
                        print("실패... 잘못된 인증코드");
                        // 잘못된 인증 코드일 때 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('잘못된 인증 코드입니다. 다시 입력해주세요.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              _gap(),
              ElevatedButton(
                onPressed:(){
                  _sendVerificationCode(_email);
                  _enteredCode = _verificationCodeController.text.trim();
                  if(_codeSent){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '인증 코드를 메일로 재발송했습니다.',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        )
                      ),
                    );
                  }
                },
                child: Text('새로운 인증 코드 받기'),
              ),
            ]
          ],
        ),

      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);

  //인증코드 보낼 메일 주소 전달
  Future<void> _sendVerificationCode(String email) async {
    print("인증 코드 발송 함수 실행됨");
    final url = Uri.parse('http://localhost:3000/email/sendVerificationCode');   // Uri.parse() : 서버의 주소를 파싱하여 Uri 객체를 생성
    //print(url);
    final response = await http.post( //POST 요청을 보냄
      url, //첫 번째 인자는 요청을 보낼 URL임.
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      //두 번째 인자는 요청 본문(body)
      body: jsonEncode({'email': email,}),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('인증 코드 전송 완료!');
      expectedCode = jsonDecode(response.body)['code'];
      print(expectedCode);
      setState(() {
        _codeSent = true; // 이메일이 성공적으로 보내졌을 때에만 _codeSent를 true로 설정
      });
    } else {
      print('인증 코드 전송 실패..');
      // 인증 코드 전송 실패 시 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 코드 전송에 실패했습니다.')),
      );
    }
  }

  // 이메일 중복 확인 함수
  Future<bool> _checkEmailExists(String email) async {
    print('이메일 중복 확인 함수 실행됨.');

    final url = Uri.parse('http://localhost:3000/checkemail?email=$email');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('이메일 중복!');
        _emailExists = true;
        // 이메일 중복 팝업 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('이미 존재하는 이메일입니다.'),
              content: Text('중복된 메일입니다. 다른 메일로 회원가입을 진행하세요.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 팝업 닫기
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        print('새로운 이메일');
        _emailExists = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('새로운 이메일! 메일로 인증코드 전송 중 ...')),
        );
      }
    } catch (e) {
      print('네트워크 오류');
      // 네트워크 오류 발생 시 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    }

    return _emailExists;
  }
}
