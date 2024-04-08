import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/smtp_server.dart';
import 'package:practice/userinfo.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();  //이메일
  final TextEditingController _verificationCodeController = TextEditingController(); //인증코드
  String _verificationCode = '';
  bool _codeSent = false;

  final formKey = GlobalKey<FormState>();  //textformfield에 입력된 값을 저장할 form
  bool _emailExists = false;  //이미 존재하는 이메일 db인지 확인 용도
  late String correctCode;

  Future<MySqlConnection> _getConnection() async {
    final settings = ConnectionSettings(
      host: 'your_mysql_host',
      port: 3306,
      user: 'your_mysql_username',
      password: 'your_mysql_password',
      db: 'your_database_name',
    );

    return await MySqlConnection.connect(settings);
  }

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
                        if (!_emailExists && _verificationCodeController.text.isEmpty)
                          buildNonDuplicateEmailWidget(),

                        // 인증 코드 입력에 대한 처리를 위한 위젯 반환
                        if (!_emailExists && _verificationCodeController.text.isNotEmpty)
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
    return !_emailExists && _verificationCodeController .text.isEmpty
        ? ElevatedButton(onPressed: _sendVerificationCode, child: Text('인증 코드 받기'),)
        : SizedBox(); // 다른 경우에는 빈 공간 반환
  }

  // 인증 코드 입력에 대한 처리를 위한 위젯 반환
  Widget buildVerificationCodeWidget() {
    return Column(
      children: [
        TextField(
          controller: _verificationCodeController,
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
        'Access-Control-Allow-Origin': '*',
      }
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
      newemail();
      setState(() {
        _emailExists = false; // 서버 요청이 실패한 경우 새로운 이메일로 간주
      });
    }
  }

  //랜덤한 6자리 인증 코드 생성해서 보냄
  Future<void> _sendVerificationCode() async {
    final random = Random();
    final verificationCode = random.nextInt(999999).toString().padLeft(6, '0'); // 6자리 랜덤 숫자 생성

    _verificationCode = verificationCode; // 인증 코드를 저장

    // SMTP 서버 설정 (Gmail 사용 예시)
    //final smtpServer = gmail('soyunamanda@gmail.com', 'ypkm qdvr pgki pbmw');
    final SmtpServer smtpServer = gmail('soyunamanda@gmail.com', 'ypkm qdvr pgki pbmw');
    /*
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
    // 이메일 제목 및 내용 설정
    final message = Message()
      ..from = Address('soyunamanda.gmail.com')
      ..recipients.add(_emailController.text) // 사용자가 입력한 이메일 주소로 설정
      ..subject = 'Verification Code'
      ..html = '<h1>Your verification code is: $_verificationCode</h1>'; // HTML 형식으로 본문 작성

    // 이메일 보내기
    try {
      await send(message, smtpServer as SmtpServer);
      print('Message sent successfully');
      setState(() {
        _codeSent = true; // 이메일이 성공적으로 보내졌을 때에만 _codeSent를 true로 설정
      });
    } catch (e) {
      print('Error occurred while sending email: $e');
    }
  }

  Future<void> _verifyCode() async {  //인증코드 일치하는지 확인
    // 입력한 인증 코드
    final enteredCode = _verificationCodeController.text;  //입력받은 인증코드
    if (enteredCode == correctCode) { // 인증 코드 일치
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

  Future <void> _submit() async {
    if(formKey.currentState!.validate() == false){
      return;
    }else{
      formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림'),
          content: Text("가입이 완료되었습니다. 로그인을 진행해주세요."),
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
        content: Text('이미 존재하는 이메일 주소입니다! 로그인을 진행해주세요.'),
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

  void newemail(){  // 이메일이 중복되지 않은 경우
    Fluttertoast.showToast(
      msg: '새로운 이메일 정보!',
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.lightBlueAccent,
      fontSize: 20,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );

    if (_verificationCodeController.text.isEmpty){
      ElevatedButton(
        onPressed: (){_sendVerificationCode();},
        child: Text('인증 코드 받기'),
      );
    }else{
      Column(
        children: [
          TextField(
            controller: _verificationCodeController,
            decoration: InputDecoration(labelText: '인증 코드를 입력해주세요.',),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed:(){_verifyCode();} ,
            child: Text('인증 확인'),
          ),
        ],
      );
    }

  }
}
