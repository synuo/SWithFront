import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'common_object.dart';
import 'login.dart';

class ChangePasswordPage extends StatefulWidget {
  final String email;

  const ChangePasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User? loggedInUser;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _changePassword() async {
    final String password = _passwordController.text;

    /*
    final userInfoResponse = await http.get(Uri.parse('http://localhost:3000/user/${widget.email}'));
    if (userInfoResponse.statusCode == 200) {
      final userData = jsonDecode(userInfoResponse.body);
      setState(() {
        final UserId = User.fromJson(userData);
      });
    }

    // 서버에서 사용자 정보 가져오기
    final userInfoResponse2 = await http.get(Uri.parse('http://localhost:3000/user/${widget.email}'));
    if (userInfoResponse2.statusCode == 200) {
      final userData = jsonDecode(userInfoResponse2.body);
      setState(() {
        loggedInUser = User.fromJson(userData);
      });
    }

     */

    // 사용자 정보를 제공받아야 함
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.loggedInUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사용자 정보가 없습니다. 다시 로그인 해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int userId = userProvider.loggedInUser!.user_id;


    final response = await http.put(
      Uri.parse('http://localhost:3000/changePassword/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비밀번호가 성공적으로 변경되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogInPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비밀번호 변경 실패: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '비밀번호 변경',
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
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _gap(),
                _gap(),
                _gap(),
                _gap(),
                Text('새 비밀번호'),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '새로운 비밀번호를 입력해주세요.';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '영문, 숫자 포함 8자 이상이어야 합니다.',
                    hintStyle: TextStyle(
                      fontSize: 12.0, // 원하는 글씨 크기
                      color: Colors.grey, // 원하는 글씨 색상 (선택 사항)
                    ),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                _gap(),
                Text('비밀번호 확인'),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인란을 입력해주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '비밀번호를 다시 입력해주세요.',
                    hintStyle: TextStyle(
                      fontSize: 12.0, // 원하는 글씨 크기
                      color: Colors.grey, // 원하는 글씨 색상 (선택 사항)
                    ),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                _gap(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _changePassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff19A7CE), // 버튼 글씨 색상
                    ),
                    child: Text(
                        '비밀번호 변경하기',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
