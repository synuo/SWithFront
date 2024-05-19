import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:practice/home.dart';
import 'package:practice/login.dart';

// 사용자 기본 정보 입력 (이름, 학번, 닉네임, 전공, 비번)
// 전공1, 전공2, 프로필이미지, 자기소개는 선택사항

class UserInfoPage extends StatefulWidget {
  final String email;

  const UserInfoPage({Key? key, required this.email}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // _formKey 정의
  List<String> _majors = [];  //전공 리스트
  String _introduction = '';  //자기소개
  final _nameController = TextEditingController();
  final _studentnumController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();  //비밀번호 확인용
  final _profileImageController = TextEditingController();    //프로필 이미지
  String _selectedMajor1 = '';
  String _selectedMajor2 = '';
  String _selectedMajor3 = '';

  bool? _isStudentIdAvailable;    //학번 중복 확인
  bool? _isNicknameAvailable;     //닉네임 중복 확인

  @override
  void initState() {
    super.initState();
    _fetchMajors();  //전공 데이터 가져옴
  }

  // 전공 이름과 ID를 매핑하는 맵
  Map<String, int> _majorIdMap = {};

  //db로부터 전공 리스트 가져옴
  Future<void> _fetchMajors() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/major'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> majors = data.cast<Map<String, dynamic>>();
        _majors = majors.map((major) => major['major_name'] as String).toList();
        _majors.insert(0, ''); // 맨 앞에 널값 추가
        setState(() {
          _selectedMajor1 = _majors.isNotEmpty ? _majors.first : ''; // 여기서 빈 문자열로 초기화
          _selectedMajor2 = _majors.isNotEmpty ? _majors.first : '';
          _selectedMajor3 = _majors.isNotEmpty ? _majors.first : '';
        });
        // _majors 리스트와 majors 데이터를 동일한 인덱스를 사용하여 전공 이름과 ID를 매핑
        _majorIdMap = Map.fromIterable(majors,
            key: (major) => major['major_name'] as String,
            value: (major) => major['major_id'] as int);
        print('_majors : $_majors');
        print('_majoridMap : $_majorIdMap');
      } else {
        throw Exception('Failed to fetch majors');
      }
    } catch (e) {
      print('Error fetching majors: $e');
    }
  }

  // dropbox에서 선택된 전공 이름에 해당하는 ID를 찾는 함수
  int? findMajorId(String majorName) {
    return _majorIdMap[majorName];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Information', style: TextStyle(color: Colors.white, fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Color(0xff19A7CE),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              // 이름 입력 폼 필드
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0,),
              // 학번 입력 폼 필드
              TextFormField(
                controller: _studentnumController,
                keyboardType: TextInputType.number, // 숫자 입력 타입 지정
                decoration: InputDecoration(
                    labelText: '학번',
                    errorText: _isStudentIdAvailable == null || _isStudentIdAvailable!
                        ? null
                        : '이미 사용 중인 학번입니다.'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '학번을 입력해주세요.';
                  }
                  if (value.length != 7) {
                    return '학번은 7자리여야 합니다.';
                  }
                  //checkDuplicateStudentId(value); // 학번 중복 체크
                  return null;
                },
              ),
              SizedBox(height: 10.0,),
              // 닉네임 입력 폼 필드
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  errorText: _isNicknameAvailable == null || _isNicknameAvailable!
                    ? null
                    : '이미 사용 중인 닉네임입니다.'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  if (value.length > 10) {
                    return '닉네임은 10자 이하여야 합니다.';
                  }
                  //checkDuplicateNickname(value);
                  return null;
                },
              ),
              SizedBox(height: 10.0,),
              // 비밀번호 입력 폼 필드
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                      .hasMatch(value)) {
                    return '비밀번호는 영문자와 숫자를 포함하여 8자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0,),
              // 비밀번호 재확인 입력 폼 필드
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;     // 비밀번호와 재확인이 일치하면 오류 없음
                },
              ),
              SizedBox(height: 10.0,),
              // 전공 선택 필드
              DropdownButtonFormField<String>(
                  value: _selectedMajor1.isNotEmpty
                      ? _selectedMajor1
                      : _majors.isNotEmpty
                      ? _majors.first
                      : '', // 초기 값 설정 및 유효성 검사
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMajor1 = newValue!;
                    });
                    print('전공1id : ${findMajorId(_selectedMajor1)}');
                },
                decoration: InputDecoration(
                  labelText: '전공',
                ),
                items: _majors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전공을 선택해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0,),
              DropdownButtonFormField<String>(
                value: _selectedMajor2,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMajor2 = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '전공 2 (선택)',
                ),
                items: _majors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 10.0,),
              DropdownButtonFormField<String>(
                value: _selectedMajor3,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMajor3 = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '전공 3 (선택)',
                ),
                items: _majors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 10.0,),
              // 프로필 이미지 등록 필드
              TextFormField(
                controller: _profileImageController, // 추가: 프로필 이미지
                decoration: InputDecoration(
                  labelText: '프로필 이미지 (선택)',
                ),
                //TODO : 사용자가 프로필 이미지 추가 (path 저장?)
              ),
              SizedBox(height: 10.0,),
              // 자기소개 입력 폼 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '자기소개 (선택)',
                ),
                maxLength: 300, // 최대 300자
                maxLines: null, // 여러 줄 입력 가능하도록 설정
                onChanged: (value) {
                  _introduction = value;
                },
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {  //회원정보가 모두 성공적으로 입력된 경우
                    // 입력된 데이터 출력 (확인용)
                    print('이메일:${widget.email}');
                    print('이름: ${_nameController.text}');
                    print('학번 : ${_studentnumController.text}');
                    print('닉네임: ${_nicknameController.text}');
                    print('비밀번호: ${_passwordController.text}');
                    print('전공1: $_selectedMajor1');
                    print('전공2: $_selectedMajor2');
                    print('전공3: $_selectedMajor3');
                    print('프로필이미지: ${_profileImageController.text}');
                    print('자기소개: $_introduction');
                    _registerUser();  // 회원 정보 저장 (=가입)
                  }
                },
                child: Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> checkDuplicateNickname(String nickname) async {
    try {
      final url = Uri.parse('http://localhost:3000/signup');
      final response = await http.post(
        url,
        body: jsonEncode({
          'nickname': nickname,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("중복된 닉네임!");
        _isNicknameAvailable = false;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('알림'),
            content: Text('이미 존재하는 닉네임입니다! 새로운 닉네임을 입력해주세요.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              )
            ],
          ),
        );
        return false;
      } else {
        print("사용 가능한 닉네임입니다.");
        return true;
      }
    } catch (e) {
      print('오류 발생: $e');
      return false;
    }
  }

  Future<bool> checkDuplicateStudentId(String studentnum) async {
    final url = Uri.parse('http://localhost:3000/signup');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'student_id': studentnum,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('알림'),
            content: Text('이미 존재하는 학번입니다! 새로운 학번을 입력해주세요.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              )
            ],
          ),
        );
        _isStudentIdAvailable = false;
        return false;
      } else {
        print("사용 가능한 학번입니다.");
        _isStudentIdAvailable = true;
        return true;
      }
    } catch (e) {
      print('오류 발생: $e');
      return false;
    }
  }

  void _registerUser() async {
    final String email = widget.email; // SignupPage에서 전달된 이메일 값
    final String name = _nameController.text;  // 이름 저장
    final String nickname = _nicknameController.text;  // 닉네임 저장
    final String password = _passwordController.text;  // 비밀번호 저장
    final String studentnum = _studentnumController.text;  //학번 저장
    final int? majorId1 = findMajorId(_selectedMajor1);
    final int? majorId2 = findMajorId(_selectedMajor2);
    final int? majorId3 = findMajorId(_selectedMajor3);
    final String profileImage = _profileImageController.text; //프로필 이미지 저장
    final String introduction = _introduction;         // 자기소개 저장

    final Uri uri = Uri.parse('http://localhost:3000/signup');

    try {    // 회원 등록을 위한 API 호출 등의 로직 추가
      final response = await http.post(    // 서버로 회원 가입 요청을 보냄
        uri,
        headers:{
          'Content-Type' : 'application/json',
        },
        body: jsonEncode({
          'email' : email,
          'name' : name,
          'nickname': nickname,
          'password': password,
          'student_id' : studentnum,
          'major1': majorId1,  //이름 대신 id 전달
          'major2': majorId2,
          'major3': majorId3,
          'profile_image': profileImage,
          'introduction' : introduction,
        }),
      );

      if (response.statusCode == 201) {  // 회원 가입 성공
        print('회원 가입 성공!');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('알림'),
            content: Text('회원 가입이 완료되었습니다! 다시 로그인을 진행해주세요.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 팝업 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogInPage()), //홈 화면으로 이동
                  );
                },
                child: Text('확인'),
              )
            ],
          ),
        );
        print('화면전환 : userinfo -> login');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          final String error = responseData['error'];
          if (error.contains('nickname')) {
            setState(() {
              _isNicknameAvailable = false;
            });
          }
          if (error.contains('student_id')) {
            setState(() {
              _isStudentIdAvailable = false;
            });
          }
        }
      } else {  // 회원 가입 실패
        print('회원 가입 실패: ${response.body}');
      }
    } catch (e) {  // 오류 발생
      print('오류 발생: $e');
    }
  }
}

