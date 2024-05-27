import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mypage.dart';
import 'common_object.dart'; // User 클래스가 정의된 파일을 임포트
import 'package:http/http.dart' as http;

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


  @override
  void dispose() {
    _nicknameController.dispose();
    _major1Controller.dispose();
    _major2Controller.dispose();
    _major3Controller.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  void _saveChanges(User user) {
    // 닉네임 중복 확인 및 전공1 변경횟수 증가 등의 로직 추가 필요
    final updatedUser = User(
      user_id: user.user_id,
      email: user.email,
      password: user.password,
      name: user.name,
      student_id: user.student_id,
      nickname: _nicknameController.text.isEmpty ? user.nickname : _nicknameController.text,
      user_image: user.user_image,
      major1: _major1Controller.text.isEmpty ? user.major1 : int.parse(_major1Controller.text),
      major2: _major2Controller.text.isEmpty ? user.major2 : int.parse(_major2Controller.text),
      major3: _major3Controller.text.isEmpty ? user.major3 : int.parse(_major3Controller.text),
      major1_change_log: user.major1_change_log + (_isMajor1Editing ? 1 : 0),
      introduction: _introductionController.text.isEmpty ? user.introduction : _introductionController.text,
      all_noti: user.all_noti,
      chatroom_noti: user.chatroom_noti,
      qna_noti: user.qna_noti,
      accept_noti: user.accept_noti,
      review_noti: user.review_noti,
    );
    Provider.of<UserProvider>(context, listen: false).updateUser(updatedUser);
    print('변경 완료!');
    print('User ID: ${updatedUser.user_id}');
    print('Email: ${updatedUser.email}');
    print('Password: ${updatedUser.password}');
    print('Name: ${updatedUser.name}');
    print('Student ID: ${updatedUser.student_id}');
    print('Nickname: ${updatedUser.nickname}');
    print('Profile Image: ${updatedUser.user_image ?? '없음'}');
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
      MaterialPageRoute(builder: (context) => MyPage()), //마이페이지 화면으로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).loggedInUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.user_image != null ? NetworkImage(user.user_image!) : null,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // 이미지 수정 로직 추가 필요
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildInfoRow('이메일', user.email),
              _buildInfoRow('이름', user.name),
              _buildInfoRow('학번', user.student_id.toString()),
              _buildEditableRow('닉네임', user.nickname, _nicknameController, _isNicknameEditing, () {
                setState(() {
                  _isNicknameEditing = !_isNicknameEditing;
                });
              }),
              /*
              _buildEditableRow('전공1', user.major1.toString(), _major1Controller, _isMajor1Editing, () {
                setState(() {
                  _isMajor1Editing = !_isMajor1Editing;
                });
              }),

               */
              _buildDropdownRow('전공1', _selectedMajor1, _isMajor1Editing, (String? value) {
                setState(() {
                  _selectedMajor1 = value;
                  print('전공1 선택: $_selectedMajor1'); // 전공1 선택 시 출력
                });
              }),
              _buildEditableRow('전공2', user.major2?.toString() ?? '', _major2Controller, _isMajor2Editing, () {
                setState(() {
                  _isMajor2Editing = !_isMajor2Editing;
                });
              }),
              _buildEditableRow('전공3', user.major3?.toString() ?? '', _major3Controller, _isMajor3Editing, () {
                setState(() {
                  _isMajor3Editing = !_isMajor3Editing;
                });
              }),
              _buildEditableRow('자기소개', user.introduction ?? '', _introductionController, _isIntroductionEditing, () {
                setState(() {
                  _isIntroductionEditing = !_isIntroductionEditing;
                });
              }, maxLines: 5),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 비밀번호 변경 화면으로 이동
                },
                child: Text('비밀번호 변경하기'),
              ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, String value, TextEditingController controller, bool isEditing, VoidCallback onEditPressed, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: isEditing
                ? TextField(
              controller: controller..text = value,
              maxLines: maxLines,
            )
                : Text(value),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(
        child: isEditing
            ? DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: _majors.map((String major) {
            return DropdownMenuItem<String>(
              value: major,
              child: Text(major),
            );
          }).toList(),
        )
            : DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue);
            },
            items: _majors.map((String major) {
              return DropdownMenuItem<String>(
                value: major,
                child: Text(major),
              );
            }).toList(),
          ),
        ),),
        ],
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
          _selectedMajor1 = _majors.isNotEmpty ? _majors.first : ''; // 여기서 빈 문자열로 초기화
          _selectedMajor2 = _majors.isNotEmpty ? _majors.first : '';
          _selectedMajor3 = _majors.isNotEmpty ? _majors.first : '';
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

  // dropbox에서 선택된 전공 이름에 해당하는 ID를 찾는 함수
  int? findMajorId(String majorName) {
    return _majorIdMap[majorName];
  }

  @override
  void initState() {
    super.initState();
    _fetchMajors();
  }
}

