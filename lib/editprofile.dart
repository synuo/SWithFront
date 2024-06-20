import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:practice/login.dart';
import 'package:provider/provider.dart';
import 'mypage.dart';
import 'common_object.dart'; // User 클래스가 정의된 파일을 임포트
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  List<String> _majors = [];  //전공 리스트

  bool _isNicknameEditing = false;
  bool _isMajor1Editing = false;
  bool _isMajor2Editing = false;
  bool _isMajor3Editing = false;
  bool _isIntroductionEditing = false;

  final _nicknameController = TextEditingController();
  final _major1Controller = TextEditingController();
  final _major2Controller = TextEditingController();
  final _major3Controller = TextEditingController();
  final _introductionController = TextEditingController();

  String? _selectedMajor1;
  String? _selectedMajor2;
  String? _selectedMajor3;
  IconData _selectedProfileIcon = Icons.person; // 기본 프로필 아이콘
  bool _isProfileIconEditing = false; // 프로필 아이콘 수정 모드

  @override
  void initState() {
    super.initState();
    _fetchMajors(); // _fetchMajors()를 initState() 내에서 호출
    _fetchSelectedMajors(); // _selectedMajor1, _selectedMajor2, _selectedMajor3을 초기화하기 위해 호출
  }

  Future<void> _fetchSelectedMajors() async {
    final user = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    _selectedMajor1 = await fetchMajorInfo(user!.major1);
    _selectedMajor2 = await fetchMajorInfo(user.major2);
    _selectedMajor3 = await fetchMajorInfo(user.major3);
    setState(() {
      _selectedProfileIcon = IconData(user.user_image ?? Icons.person.codePoint, fontFamily: 'MaterialIcons');
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _major1Controller.dispose();
    _major2Controller.dispose();
    _major3Controller.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).loggedInUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로필 수정',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        //centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*
              CircleAvatar(
                radius: 50,
                child: Icon(
                  _selectedProfileIcon,
                  size: 50,
                ),
                backgroundColor: Colors.grey,
              ),

               */
              Padding(
                padding: const EdgeInsets.only(left: 80.0), // 원하는 오른쪽 이동 거리 설정
                child: Center(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<IconData>(
                      value: _selectedProfileIcon,
                      items: [
                        DropdownMenuItem(
                          value: Icons.person,
                          child: CircleAvatar(
                            radius: 150,
                            backgroundColor: Colors.white, // 배경색 설정
                            child: Icon(Icons.person, size: 50, color: Color(0xff19A7CE)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Icons.cookie,
                          child: CircleAvatar(
                            radius: 150,
                            backgroundColor: Colors.white, // 배경색 설정
                            child: Icon(Icons.cookie, size: 50, color: Color(0xff19A7CE)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: Icons.ac_unit,
                          child: CircleAvatar(
                            radius: 150,
                            backgroundColor: Colors.white, // 배경색 설정
                            child: Icon(Icons.ac_unit, size: 50, color: Color(0xff19A7CE)),
                          ),
                        ),
                      ],
                      onChanged: (IconData? newIcon) {
                        setState(() {
                          _selectedProfileIcon = newIcon!;
                        });
                      },
                      icon: Container(), // 아이콘 비워두기
                      isExpanded: true,
                      alignment: Alignment.center, // 아이템 텍스트 정렬 설정
                      //alignment: Alignment(0.5, 0.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              //_buildProfileIconRow(),
              _buildInfoRow('이메일', user.email),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildInfoRow('이름', user.name),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildInfoRow('학번', user.student_id.toString()),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildEditableRow('닉네임', user.nickname, _nicknameController, _isNicknameEditing, () {
                setState(() {
                  _isNicknameEditing = !_isNicknameEditing;
                });
              }),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildDropdownRow('전공1', _selectedMajor1, _isMajor1Editing, (String? value) {
                setState(() {
                  if(_selectedMajor1 == value){
                    _isMajor1Editing = true;
                  }
                  _selectedMajor1 = value;
                  print('전공1 선택: $_selectedMajor1'); // 전공1 선택 시 출력
                });
              }),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildDropdownRow('전공2', _selectedMajor2, _isMajor2Editing, (String? value) {
                setState(() {
                  _selectedMajor2 = value;
                  print('전공2 선택: $_selectedMajor2'); // 전공2 선택 시 출력
                });
              }),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildDropdownRow('전공3', _selectedMajor3, _isMajor3Editing, (String? value) {
                setState(() {
                  _selectedMajor3 = value;
                  print('전공3 선택: $_selectedMajor3'); // 전공3 선택 시 출력
                });
              }),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 5),
              _buildEditableRow('자기소개', user.introduction ?? '', _introductionController, _isIntroductionEditing, () {
                setState(() {
                  _isIntroductionEditing = !_isIntroductionEditing;
                });
              }, maxLines: 5),
              SizedBox(height: 20),
              SizedBox(height: 20),
              Divider(height: 1, color: Color(0xff19A7CE)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveChanges(user);
                },
                child: Text('저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges(User user) async {
    // 닉네임 중복 확인 및 전공1 변경횟수 증가 등의 로직 추가 필요
    final updatedUser = User(
      user_id: user.user_id,
      email: user.email,
      password: user.password,
      name: user.name,
      student_id: user.student_id,
      nickname: _nicknameController.text.isEmpty ? user.nickname : _nicknameController.text,
      user_image: _selectedProfileIcon.codePoint, // 프로필 아이콘의 codePoint를 문자열로 저장
      major1: _selectedMajor1 != null && _selectedMajor1!.isNotEmpty ? findMajorId(_selectedMajor1!)! : user.major1,
      major2: _selectedMajor2 != null && _selectedMajor2!.isNotEmpty ? findMajorId(_selectedMajor2!) : user.major2,
      major3: _selectedMajor3 != null && _selectedMajor3!.isNotEmpty ? findMajorId(_selectedMajor3!) : user.major3,
      major1_change_log: user.major1_change_log + (_isMajor1Editing ? 1 : 0),
      introduction: _introductionController.text.isEmpty ? user.introduction : _introductionController.text,
      all_noti: user.all_noti,
      chatroom_noti: user.chatroom_noti,
      qna_noti: user.qna_noti,
      accept_noti: user.accept_noti,
      review_noti: user.review_noti,
    );
    try{
      final response = await http.put(
        Uri.parse('http://localhost:3000/user/${user.user_id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedUser.toJson()), // toJson 메서드를 이용하여 JSON으로 변환
      );
      if (response.statusCode == 200) {
        Provider.of<UserProvider>(context, listen: false).updateUser(updatedUser);
        print('변경 완료!');
        print('User ID: ${updatedUser.user_id}');
        print('Email: ${updatedUser.email}');
        print('Password: ${updatedUser.password}');
        print('Name: ${updatedUser.name}');
        print('Student ID: ${updatedUser.student_id}');
        print('Nickname: ${updatedUser.nickname}');
        print('Profile Icon: ${updatedUser.user_image}');
        print('Major 1: ${updatedUser.major1}');
        print('Major 2: ${updatedUser.major2 ?? '없음'}');
        print('Major 3: ${updatedUser.major3 ?? '없음'}');
        print('Major1 Changed: ${updatedUser.major1_change_log}');
        print('Introduction: ${updatedUser.introduction ?? '없음'}');
        print('all_noti: ${updatedUser.all_noti}');
        print('chatroom_noti: ${updatedUser.chatroom_noti}');
        print('qna_noti: ${updatedUser.qna_noti}');
        print('accept_noti: ${updatedUser.accept_noti}');
        print('review_noti: ${updatedUser.review_noti}');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPage()), // 마이페이지 화면으로 이동
        );
      } else {
        print('Failed to update user. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update user');
      }
    }catch(e){
      print('Error updating user: $e');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
          Text(value, style: TextStyle(fontSize: 15.0)),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, String value, TextEditingController controller, bool isEditing, VoidCallback onEditPressed, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: isEditing
                  ? TextField(
                controller: controller..text = value,
                maxLines: maxLines,
              )
                  : Text(value, style: TextStyle(fontSize: 15.0)),
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String? value, bool isEditing, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
          Expanded(
            child: isEditing
                ? DropdownSearch<String>(
              items: _majors,
              selectedItem: value,
              onChanged: onChanged,
              dropdownBuilder: (context, selectedItem) => Text(selectedItem ?? ''),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                constraints: BoxConstraints(maxHeight: 200), // 드롭다운 높이 제한
              ),
            )
                : DropdownSearch<String>(
              items: _majors,
              selectedItem: value != null ? value : (_majors.isNotEmpty ? _majors.first : null),
              onChanged: (newValue) {
                if (label == '전공1') {
                  _selectedMajor1 = newValue!;
                } else if (label == '전공2') {
                  _selectedMajor2 = newValue!;
                } else if (label == '전공3') {
                  _selectedMajor3 = newValue!;
                }
                onChanged(newValue);
              },
              dropdownBuilder: (context, selectedItem) => Text(selectedItem ?? ''),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                constraints: BoxConstraints(maxHeight: 200), // 드롭다운 높이 제한
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 프로필 아이콘 선택을 위한 Row 빌더
  Widget _buildProfileIconRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<IconData>(
            value: _selectedProfileIcon,
            items: [
              DropdownMenuItem(
                value: Icons.person,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 50, color : Color(0xff19A7CE)),
                ),
              ),
              DropdownMenuItem(
                value: Icons.cookie,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.cookie, size: 50, color : Color(0xff19A7CE)),
                ),
              ),
              DropdownMenuItem(
                value: Icons.ac_unit,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.ac_unit, size: 50, color : Color(0xff19A7CE)),
                ),
              ),
            ],
            onChanged: (IconData? newIcon) {
              setState(() {
                _selectedProfileIcon = newIcon!;
              });
            },
            icon: Container(), // 아이콘 비워두기
            isExpanded: true,
            alignment: Alignment.center, // 아이템 텍스트 정렬 설정
          ),
        ),
      ),
    );
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
          _selectedMajor1; // 여기서 빈 문자열로 초기화
          _selectedMajor2;
          _selectedMajor3; // = _majors.isNotEmpty ? _majors.first : '';
        });

        // _majors 리스트와 majors 데이터를 동일한 인덱스를 사용하여 전공 이름과 ID를 매핑
        _majorIdMap = Map.fromIterable(majors,
            key: (major) => major['major_name'] as String,
            value: (major) => major['major_id'] as int);
      } else {
        throw Exception('Failed to fetch majors');
      }
    } catch (e) {
      print('Error fetching majors: $e');
    }
  }

  // 전공 정보를 가져오는 메서드
  Future<String?> fetchMajorInfo(int? majorId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 데이터를 파싱
        return data['major_name'];
      } else {
        throw Exception('Failed to load major information');
      }
    } catch (error) {
      print('Error fetching major information: $error');
    }
  }

  // dropbox에서 선택된 전공 이름에 해당하는 ID를 찾는 함수
  int? findMajorId(String majorName) {
    return _majorIdMap[majorName];
  }
}
