import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/login.dart';
import 'package:practice/resetpassword.dart';
import 'dart:convert';

class FindPasswordPage extends StatefulWidget {
  @override
  _FindPasswordPageState createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController(); //이메일 입력받음
  final TextEditingController _verificationCodeController = TextEditingController(); //인증코드 입력받음
  late String _email;             //사용자 이메일
  late String _enteredCode;      //사용자가 입력한 코드
  bool emailValid = false;
  bool _codeSent = false;    // 인증코드 전송 여부
  bool _emailExists = false; //이미 존재하는 이메일 db인지 확인 용도
  late String expectedCode;  //인증코드를 저장하는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Scaffold 위젯 추가
      appBar: AppBar(
        title: Text(
          '비밀번호 찾기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // 선의 두께를 설정합니다.
          child: Container(
            color: Colors.black12, // 선의 색상을 설정합니다.
            height: 1.0, // 선의 높이를 설정합니다.
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '비밀번호 찾기를 위해 이메일 인증을 진행해주세요.',
                  style: TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.normal),
                ),
                _gap(),
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
                    labelText: '이메일',
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
                      if(emailValid && _emailExists){
                        _email = _emailController.text;
                        await _sendVerificationCode(_email);
                      }
                    },
                  ),
                ),
                _gap(),
                if (_codeSent) ...[
                  Text(
                    '인증 코드 6자리가 메일로 전송되었습니다.\n',
                    style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.normal),
                  ),
                  TextFormField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      labelText: '인증 코드',
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
                              MaterialPageRoute(builder: (context) => ChangePasswordPage(email : _email)),
                            );
                            print('화면전환 : findpw -> resetpw');
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
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);

  //인증코드 보낼 메일 주소 전달
  Future<void> _sendVerificationCode(String email) async {
    print("인증 코드 발송 함수 실행됨");
    final url = Uri.parse('http://localhost:3000/email/sendVerificationCode');   // Uri.parse() : 서버의 주소를 파싱하여 Uri 객체를 생성
    final response = await http.post( //POST 요청을 보냄
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
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
        print('존재하는 이메일 정보!');
        _emailExists = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메일로 인증코드 전송 중 ...')),
        );
      } else {
        print('존재하지 않는 이메일 정보..');
        _emailExists = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('존재하지 않는 이메일 정보.'),
              content: Text('존재하지 않는 이메일 정보입니다. 회원가입을 진행하세요.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 팝업 닫기
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LogInPage()),
                    );
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('네트워크 오류');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    }

    return _emailExists;
  }

}
