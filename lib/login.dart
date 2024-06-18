import 'package:flutter/material.dart';
import 'package:practice/main.dart';
import 'package:practice/home.dart';
import 'package:http/http.dart' as http;
import 'package:practice/signup.dart';
import 'dart:convert';
import 'dart:async';
import 'findpw.dart';
import 'common_object.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late User loggedInUser;

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);
  @override
  State<LogInPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LogInPage> {

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      await login(context, autoLogin: true);
    }
  }

  Future <void> login(BuildContext context, {bool autoLogin = false}) async {  //로그인 처리 함수
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

      final responseData = jsonDecode(response.body);
      final user_id = responseData['user_id'];  // 유저 아이디 받아옴
      print('User ID: $user_id');

      // 서버에서 사용자 정보 가져오기
      final userInfoResponse = await http.get(Uri.parse('http://localhost:3000/user/$user_id'));
      if (userInfoResponse.statusCode == 200) {
        final userData = jsonDecode(userInfoResponse.body);
        final loggedInUser = User.fromJson(userData);

        Provider.of<UserProvider>(context, listen: false).setLoggedInUser(loggedInUser); // Provider로 loggedInUser 설정

        if (_rememberMe && !autoLogin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', _emailController.text);
          await prefs.setString('password', _passwordController.text);
        }

        print('User ID: ${loggedInUser.user_id}');
        print('Email: ${loggedInUser.email}');
        print('Password: ${loggedInUser.password}');
        print('Name: ${loggedInUser.name}');
        print('Student ID: ${loggedInUser.student_id}');
        print('Nickname: ${loggedInUser.nickname}');
        print('Profile Image: ${loggedInUser.user_image ?? '없음'}');
        print('Major 1: ${loggedInUser.major1}');
        print('Major 2: ${loggedInUser.major2 ?? '없음'}');
        print('Major 3: ${loggedInUser.major3 ?? '없음'}');
        print('Major1 Changed: ${loggedInUser.major1_change_log}');
        print('Introduction: ${loggedInUser.introduction ?? '없음'}');
        print('all_noti: ${loggedInUser.all_noti}');
        print('chatroom_noti: ${loggedInUser.chatroom_noti}');
        print('qna_noti: ${loggedInUser.qna_noti}');
        print('accept_noti: ${loggedInUser.accept_noti}');
        print('review_noti: ${loggedInUser.review_noti}');
      } else {
        // 사용자 정보를 가져오는 데 실패한 경우
        print('Failed to fetch user information');
      }

      print('화면전환 : login -> homepage ');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user_id: user_id,)),
      ); // 로그인 성공 시 홈으로 이동. 유저아이디도 같이 전달.
    } else {
      print('Log in failed..');
      print(response.statusCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            ))
    );

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
                labelText: '이메일',
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
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력해주세요.',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff19A7CE),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '로그인',
                    style: TextStyle(color : Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    print("로그인 버튼 클릭함");
                    print(_emailController.text);
                    print(_passwordController.text);
                    await login(context);
                  }
                },
              ),
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
              title: const Text('로그인 상태 유지'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(),
            Text(
                '-----------------------------  또는  -----------------------------'
            ),

            _gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => FindPasswordPage()),
                    );
                    print('화면전환 : login -> findpw');
                  },
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      //color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                    print('화면전환 : login -> signup');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 패딩 추가
                    child: Text(
                      '회원 가입',
                      style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        //color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }


  Future <void> login(BuildContext context, {bool autoLogin = false}) async {  //로그인 처리 함수
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

      final responseData = jsonDecode(response.body);
      final user_id = responseData['user_id'];  // 유저 아이디 받아옴
      print('User ID: $user_id');

      // 서버에서 사용자 정보 가져오기
      final userInfoResponse = await http.get(Uri.parse('http://localhost:3000/user/$user_id'));
      if (userInfoResponse.statusCode == 200) {
        final userData = jsonDecode(userInfoResponse.body);
        final loggedInUser = User.fromJson(userData);

        Provider.of<UserProvider>(context, listen: false).setLoggedInUser(loggedInUser); // Provider로 loggedInUser 설정

        if (_rememberMe && !autoLogin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', _emailController.text);
          await prefs.setString('password', _passwordController.text);
        }

        print('User ID: ${loggedInUser.user_id}');
        print('Email: ${loggedInUser.email}');
        print('Password: ${loggedInUser.password}');
        print('Name: ${loggedInUser.name}');
        print('Student ID: ${loggedInUser.student_id}');
        print('Nickname: ${loggedInUser.nickname}');
        print('Profile Image: ${loggedInUser.user_image ?? '없음'}');
        print('Major 1: ${loggedInUser.major1}');
        print('Major 2: ${loggedInUser.major2 ?? '없음'}');
        print('Major 3: ${loggedInUser.major3 ?? '없음'}');
        print('Major1 Changed: ${loggedInUser.major1_change_log}');
        print('Introduction: ${loggedInUser.introduction ?? '없음'}');
        print('all_noti: ${loggedInUser.all_noti}');
        print('chatroom_noti: ${loggedInUser.chatroom_noti}');
        print('qna_noti: ${loggedInUser.qna_noti}');
        print('accept_noti: ${loggedInUser.accept_noti}');
        print('review_noti: ${loggedInUser.review_noti}');
      } else {
        // 사용자 정보를 가져오는 데 실패한 경우
        print('Failed to fetch user information');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 성공'),
          backgroundColor: Colors.green,
        ),
      );
      print('화면전환 : login -> homepage ');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user_id: user_id,)),
      ); // 로그인 성공 시 홈으로 이동. 유저아이디도 같이 전달.
    } else if (response.statusCode == 401){
      print('Invalid password or email..');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 정보가 올바르지 않습니다. 다시 시도해주세요!'),
          backgroundColor: Colors.red,
        ),
      );

    }else {
      print('Log in failed..');
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