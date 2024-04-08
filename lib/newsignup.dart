import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:practice/userinfo.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:practice/main.dart';
import 'package:practice/userinfo.dart';

// Form 위젯에 대한 GlobalKey 선언
final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();

class newSignupPage extends StatefulWidget {
  const newSignupPage({Key? key}) : super(key: key);
  @override
  State<newSignupPage> createState() => _newSignupPageState();
}

class _newSignupPageState extends State<newSignupPage> {
  int _currentStep = 0;
  late TextEditingController _emailController;
  late TextEditingController _codeController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _introductionController;

  Map<String, dynamic> userInputData = {};

  @override
  void initState(){
    super.initState();
    _emailController = TextEditingController();  //이메일
    _codeController = TextEditingController();   //인증코드
    _passwordController = TextEditingController(); //비밀번호
    _confirmPasswordController = TextEditingController(); //비밀번호 재확인
    _nameController = TextEditingController(); //이름
    _nicknameController = TextEditingController(); //닉네임
    _introductionController = TextEditingController(); //자기소개
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  List<Step> stepList = [
    Step(
        title: Text("이메일 입력"),
        content: Form(
          key: emailFormKey,
          child: TextFormField(
            controller: controllers['email'],
            decoration: const InputDecoration(
              hintText: "이메일을 입력해주세요 :)",
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => userInputData['email'] = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일은 반드시 입력 해야 합니다!';
              }
              if (!EmailValidator.validate(value)) {
                return '유효한 이메일을 입력해 주세요!';
              }
              if (!validation['email']!) {
                return '이미 등록된 이메일 입니다!';
              }
              return null;
            },
          ),
        ),
      isActive: true,
    ), //이메일 입력 단게
    Step(
      title: Text('인증코드 입력'),
      content: Column(
        children: [
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(labelText: '인증코드'),
          ),
        ],
      ),
      isActive: false,
    ), //인증코드 입력 단계
    Step(
      title: Text('비밀번호 입력'),
      content: Column(
        children: [
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: '비밀번호'),
            obscureText: true,
          ),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(labelText: '비밀번호 확인'),
            obscureText: true,
          ),
        ],
      ),
      isActive: false,
    ), //비밀번호 입력 단계
    Step(
      title: Text('개인정보 입력'),
      content: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '이름'),
          ),
          TextFormField(
            controller: _nicknameController,
            decoration: InputDecoration(labelText: '이름'),
          ),
        ],
      ),
      isActive: false,
    ),
    Step(
      title: Text('자기소개 입력 (선택사항)'),
      content: Column(
        children: [
          TextFormField(
            controller: _introductionController,
            decoration: InputDecoration(labelText: '자기소개'),
            maxLines: 3,
          ),
        ],
      ),
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    MyApp.screenSize = MediaQuery.of(context) as Size?;

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: SizedBox(
            height: MyApp.screenSize?.height ?? 0,
            width: MyApp.screenSize?.width ?? 0,
            child: Stepper(
              steps: stepList,              //화면에 보여줄 스텝 리스트
              type: StepperType.vertical,  //step 을 수직으로 보여줌
              elevation: 0,                //step 높이 설정
              currentStep: _currentStep,   //현재 표시되는 스텝의 index 값
              onStepTapped: (int index){
                setState(() {
                  _currentStep = index;
                });
              },  //스텝들을 탭 했을 때, 동작할 로직
              onStepContinue: (){
                switch (_currentStep) {
                  case 0:
                    emailValidCheck().then((value) {
                      if (value) {
                        setState(() {
                          log(userInputData.toString());
                          _currentStep += 1;
                        });
                      }
                    });
                    break;
                  case 1:
                    if (passwordValidCheck()) {
                      if (passwordValidDoubleCheck()) {
                        userInputData['password'] = controllers['password']!.text;
                        setState(() {
                          _currentStep += 1;
                        });
                      }
                    }
                    break;
                  case 2:
                    userIdValidCheck().then((value) {
                      if (value) {
                        userInputData['userId'] = controllers['userId']!.text;
                        if (nameValidCheck() &&
                            birthValidCheck() &&
                            genderValidCheck()) {
                          dbService.registerUser(User(
                              email: userInputData['email'],
                              birth: userInputData['birth'],
                              userId: userInputData['userId'],
                              nickname: userInputData['nickname'],
                              password: userInputData['password']));
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => LoginPage()),
                                  (route) => false);
                        } else {}
                      }
                    });
                }
              },         //다음 버튼을 탭 했을 때, 동작할 로직을 구현
              onStepCancel: (){
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              }, //취소 버튼을 탭 했을 때, 동작할 로직을 구현
            ),
          ),
        ),
      ),
    );
  }

  void _handleFailureResponse(int statusCode, String responseBody) async {
    // 서버 응답이 실패했을 때 사용자에게 알리는 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('회원가입 실패'),
        content: Text('서버 응답 코드: $statusCode\n서버 응답: $responseBody'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String nickname = _nicknameController.text;
    String introduction = _introductionController.text;

    // 서버에 전송할 데이터
    Map<String, dynamic> userData = {
      'email': email,
      'password': password,
      'name': name,
      'nickname' : nickname,
      'introduction': introduction,
    };

    // 서버 API 엔드포인트 URL
    String apiUrl = 'http://localhost:3000/signup';
    try {
      // HTTP POST 요청 전송
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      // 서버 응답 확인
      if (response.statusCode == 200) {
        // 회원가입 성공 시 로그인 화면으로 이동
        print('서버 응답: ${response.body}');  //서버 응답 출력
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // 회원가입 실패 시 처리
        print('서버 응답 코드: ${response.statusCode}');
        print('서버 응답: ${response.body}');
        // TODO : 실패에 대한 사용자에게 알리는 등의 처리를 추가
        _handleFailureResponse(response.statusCode, response.body);
      }
    } catch (e) {
      print('오류 발생: $e');  // 오류 발생 시 처리

      showDialog(   // 사용자에게 오류를 알리는 다이얼로그 표시
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('회원가입 중 오류가 발생했습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  Future <bool> emailValidCheck() async{
    await emailDuplicateCheck();
    return emailFormKey.currentState!.validate();
  }

  Future<void> userIdValidCheck() async {
    // userId 유효성 검사 코드 추가
  }

  Future<void> emailDuplicateCheck() async {
    // 서버에 이메일 중복 확인 요청을 보내고 응답을 처리하는 코드 추가
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('userInputData', userInputData));
  }

}
