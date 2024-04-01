import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:practice/userinfo.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();  //이메일
  final TextEditingController _codeController = TextEditingController();   //인증코드
  final formKey = GlobalKey<FormState>();  //textformfield에 입력된 값을 저장할 form
  bool _emailExists = false;  //이미 존재하는 이메일 db인지 확인 용도
  late String correctCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입', style: TextStyle(color: Colors.white, fontSize: 20.0),),
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
      body: Form(
        key : formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Center(child: Icon(Icons.cookie)),
              Form(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.white,
                    inputDecorationTheme: InputDecorationTheme(labelStyle: TextStyle(color: Color(0xff19A7CE), fontSize: 15.0),),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(60.0),
                    child : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(labelText: '숙명 이메일을 입력해주세요.'),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () async {
                                print("중복 확인 버튼 클릭함");
                                await _checkEmailExists();   //이메일 정보 확인 함수
                                print(_emailController.text);  //입력된 이메일 확인용
                              },
                              child: Text('중복 확인', style: TextStyle(color: Colors.white, fontSize: 15.0),),
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xff19A7CE)),
                            ),
                          ],
                        ),
                        // 중복되지 않은 경우에만 버튼을 표시
                        if (!_emailExists && _codeController.text.isEmpty)
                          buildNonDuplicateEmailWidget(),

                        // 인증 코드 입력에 대한 처리를 위한 위젯 반환
                        if (!_emailExists && _codeController.text.isNotEmpty)
                          buildVerificationCodeWidget(),
                      ],
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

  // 중복되지 않은 경우에 대한 처리를 위한 위젯 반환
  Widget buildNonDuplicateEmailWidget() {
    /*
    return ElevatedButton(
      onPressed: _sendVerificationCode,
      child: Text('인증 코드 받기'),
    );
    */
    return !_emailExists && _codeController.text.isEmpty
        ? ElevatedButton(onPressed: _sendVerificationCode, child: Text('인증 코드 받기'),)
        : SizedBox(); // 다른 경우에는 빈 공간 반환
  }

  // 인증 코드 입력에 대한 처리를 위한 위젯 반환
  Widget buildVerificationCodeWidget() {
    return Column(
      children: [
        TextField(
          controller: _codeController,
          decoration: InputDecoration(labelText: '인증 코드를 입력해주세요.'),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _verifyCode,
          child: Text('인증 확인'),
        ),
      ],
    );
  }

  // 이메일 중복 여부를 확인
  Future<void> _checkEmailExists() async {
    print('이메일 중복 확인 함수 실행됨.');
    //서버에 이메일 확인
    final response = await http.get(
      Uri.parse('http://localhost:3000/checkemail?email=${_emailController.text}'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      print('이미 존재하는 email');
      final jsonResponse = jsonDecode(response.body);
      knownemail();
      setState(() {
        _emailExists = jsonResponse['exists'] == 1;
      });
    }else{
      print('새로운 email 주소.');
      setState(() {
        _emailExists = false; // 서버 요청이 실패한 경우 새로운 이메일로 간주
      });
    }





    /*
    if (!_emailExists && _codeController.text.isEmpty){
      // 중복되지 않은 경우에 대한 처리
      ElevatedButton(
        onPressed: _sendVerificationCode,
        child: Text('인증 코드 받기'),
      );
    }
    */

    if(!_emailExists && _codeController.text.isNotEmpty){
      Column(
        children: [
          TextField(
            controller: _codeController,
            decoration: InputDecoration(labelText: '인증 코드를 입력해주세요.',),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _verifyCode,
            child: Text('인증 확인'),
          ),
        ],
      );
    }
    /* else {  // 서버 요청이 실패한 경우에 대한 처리
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('에러'),
          content: Text('서버 요청이 실패했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }*/
  }

  Future<void> _sendVerificationCode() async {  //랜덤한 4자리 인증 코드 생성해서 보냄
    final random = Random();
    final verificationCode = '${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}';
    correctCode = verificationCode; // 인증 코드를 저장
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
  }

  Future<void> _verifyCode() async {  //인증코드 일치하는지 확인
    // 입력한 인증 코드
    final enteredCode = _codeController.text;  //입력받은 인증코드
    if (enteredCode == correctCode) { // 인증 코드 일치
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserInfoPage()),
      );
    } else {
      // 인증 코드 불일치
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('잘못된 인증 코드입니다. 다시 시도해주세요.'),),);
      _codeController.clear();  // 인증 코드 입력 필드 초기화
    }
  }

  Future <void> _submit() async {
    if(formKey.currentState!.validate() == false){
      return;
    }else{
      formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("가입이 완료되었습니다. 로그인을 진행해주세요."),
            duration: Duration(seconds: 2),
        )
      );
      Navigator.of(context).pop();
    }
  }

  void knownemail(){   // 이메일이 중복된 경우
    Fluttertoast.showToast(
      msg: '이미 존재하는 이메일!',
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.lightBlueAccent,
      fontSize: 20,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('알림'),
        content: Text('이미 존재하는 이메일 주소입니다!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 화면으로 이동
              );},
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void newemail(){

  }
}
