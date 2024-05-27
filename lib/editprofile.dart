import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice/mypage.dart';
import 'package:practice/notifications.dart';
import 'package:practice/post_detail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'board.dart';
import 'chat.dart';
import 'common_object.dart';
import 'common_widgets.dart';
import 'package:http/http.dart' as http;

//프로필이미지, 이메일, 이름, 학번, 닉네임, 전공1, 전공2, 전공3, 자기소개 (이 순서대로)를 보여줌
//닉네임, 전공1,전공2, 전공3, 프로필이미지, 자기소개 우측에는 수정 버튼이 존재해서 수정 가능함
//닉네임은 중복 확인 필요
//전공1,2,3 은 전공리스트에서 선택함
//변경된 정보 유저정보에 저장
//전공 1 변경 시 _major1changed true로 변경

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // _formKey 정의

  final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentidController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _nicknameController = TextEditingController();
  bool? _isNicknameAvailable;
  final TextEditingController _introductionController = TextEditingController();

  List<String> _majors = [];  //전공 리스트
  late String _selectedMajor1;
  String? _selectedMajor2;
  String? _selectedMajor3;
  late int _major1changed;

  bool _isEditingNickname = false;
  bool _isEditingIntroduction = false;

  // 전공 이름과 ID를 매핑하는 맵
  Map<String, int> _majorIdMap = {};

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    if (user != null) {   //화면에 표시하기 위해 기존 정보 받아옴
      _nicknameController.text = user.nickname;
      _nameController.text = user.name;
      _studentidController.text = user.student_id.toString();
      _emailController.text = user.email;
      _profileImageController.text = user.user_image ?? '';
      _introductionController.text = user.introduction ?? '';
      _major1changed = user.major1_change_log;
      fetchMajorInfo(1, user.major1);    //전공은 id로 받아온걸 이름으로 변경
      if (user.major2 != null) {
        fetchMajorInfo(2, user.major2);
      }else{
        _selectedMajor2 = '선택 안함';
      }
      if (user.major3 != null) {
        fetchMajorInfo(3, user.major3);
      }else{
        _selectedMajor3 = '선택 안함';
      }
    }
  }

  //main
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit your Profile'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: ListView(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileImageController != null
                      ? NetworkImage(_profileImageController.text)
                      : AssetImage('assets/default_profile.png') as ImageProvider,
                ),
                IconButton(
                    onPressed: (){
                      _getImageFromGallery();
                    },
                    icon: Icon(Icons.edit_outlined)
                ),
                SizedBox(height: 20),
                _buildEditableField(
                  labelText: '닉네임',
                  controller: _nicknameController,
                  isEditing: _isEditingNickname,
                  onEditPressed: () {
                    setState(() {
                      _isEditingNickname = !_isEditingNickname;
                    });
                  },
                  onSave: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      bool isAvailable = await checkDuplicateNickname(_nicknameController.text);
                      if (isAvailable) {
                        setState(() {
                          _isEditingNickname = false;
                        });
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요.';
                    }
                    if (value.length > 10) {
                      return '닉네임은 10자 이하여야 합니다.';
                    }
                    return null;
                  },
                  errorText: _isNicknameAvailable == null || _isNicknameAvailable!
                      ? null
                      : '이미 사용 중인 닉네임입니다.',
                ),
                /*
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: '닉네임',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.edit_outlined),
                      onPressed: () => checkDuplicateNickname(_nicknameController.text),
                    ),
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

                 */
                _gap(),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '이름'),
                  readOnly: true,
                ),
                _gap(),
                TextField(
                  controller: _studentidController,
                  decoration: InputDecoration(labelText: '학번'),
                  readOnly: true,
                ),
                _gap(),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: '이메일'),
                  readOnly: true,
                ),
                //TODO : 전공 1,2,3 수정하기
                //기존 전공 1,2,3이 나타남.
                //우측의 수정 아이콘을 누르면 전공 리스트를 보여주고 여기서 새로운 전공을 선택하여 수정 가능함.
                _gap(),
                DropdownButtonFormField<String>(
                  value: _selectedMajor1,
                  items: _majors.map((String major) {
                    return DropdownMenuItem<String>(
                      value: major,
                      child: Text(major),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if(newValue != _selectedMajor1){
                        _selectedMajor1 = newValue!;
                        _major1changed++;  //전공1 변경 횟수 +1
                      }
                    });
                  },
                  decoration: InputDecoration(labelText: '전공 1 : $_selectedMajor1'),
                ),
                _gap(),
                DropdownButtonFormField<String>(
                  value: _selectedMajor2,
                  items: _majors.map((String major) {
                    return DropdownMenuItem<String>(
                      value: major,
                      child: Text(major),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMajor2 = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: '전공 2 : $_selectedMajor2'),
                ),
                _gap(),
                DropdownButtonFormField<String>(
                  value: _selectedMajor3,
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
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMajor3 = newValue!;
                    });
                    _fetchMajors();
                  },
                  decoration: InputDecoration(labelText: '전공 3 : $_selectedMajor3'),
                ),
                _gap(),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '자기소개 (선택)',
                    hintText: '본인에 대해 간단히 소개해주세요. (300자 이하) ',
                    border: OutlineInputBorder(),
                  ),
                  controller : _introductionController,
                  maxLength: 300, // 최대 300자
                ),
                ElevatedButton(
                  onPressed: () async {
                    // TODO : 비밀번호 변경하기
                  },
                  child: Text('비밀번호 변경하기'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    _saveProfile();  // 변경된 회원 정보 저장
                  },
                  child: Text('변경 완료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    final user = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final updatedUser = User(
      user_id: user!.user_id,
      accept_noti: user.accept_noti,
      all_noti: user.all_noti,
      chatroom_noti: user.chatroom_noti,
      qna_noti: user.qna_noti,
      review_noti: user.review_noti,
      password: user!.password,
      email: user!.email,
      name: user!.name,
      student_id: user!.student_id,
      nickname: _nicknameController.text,
      major1: _majorIdMap[_selectedMajor1]!,
      major2: _majorIdMap[_selectedMajor2]!,
      major3: _majorIdMap[_selectedMajor3]!,
      introduction: _introductionController.text,
      user_image: user!.user_image,
      major1_change_log: _major1changed,
    );
    Provider.of<UserProvider>(context, listen: false).updateUser(updatedUser);
    Navigator.pop(context);

  }

  Widget _buildMajorField(int fieldNumber, String? selectedMajor) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(labelText: '전공 $fieldNumber : $selectedMajor'),
            readOnly: true,
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _showMajorSelectionDialog(fieldNumber),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String labelText,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditPressed,
    required VoidCallback onSave,
    String? Function(String?)? validator,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            suffixIcon: isEditing
                ? IconButton(
              icon: Icon(Icons.check),
              onPressed: onSave,
            )
                : IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEditPressed,
            ),
            errorText: errorText,
          ),
          readOnly: !isEditing,
          validator: validator,
        ),
        if (validator != null && isEditing)
          Text(
            errorText ?? '',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  //db로부터 전공 리스트 가져옴
  Future<void> _fetchMajors() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/major'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> majors = data.cast<Map<String, dynamic>>();
        _majors = majors.map((major) => major['major_name'] as String).toList();
        _majors.insert(0, ''); // 맨 앞에 널값 추가
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

  // 전공 id를 통해 전공 이름을 가져오고 변수에 저장
  Future<void> fetchMajorInfo(int fieldNumber, int? majorId) async {
    try {
      if (majorId != null){
        final response = await http.get(Uri.parse('http://localhost:3000/majorDetail/$majorId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body); // JSON 데이터를 파싱
          setState(() {
            switch (fieldNumber) {
              case 1:
                _selectedMajor1 = data['major_name']; // 전공 이름을 저장
                break;
              case 2:
                _selectedMajor2 = data['major_name']; // 전공 이름을 저장
                break;
              case 3:
                _selectedMajor3 = data['major_name']; // 전공 이름을 저장
                break;
              default:
            }
          });
        }
      } else {
        setState(() {
          switch (fieldNumber) {
            case 1:
              _selectedMajor1 = ''; // 전공 이름을 저장
              break;
            case 2:
              _selectedMajor2 = ''; // 전공 이름을 저장
              break;
            case 3:
              _selectedMajor3 = ''; // 전공 이름을 저장
              break;
            default:
          }
        });
      }
    } catch (error) {
      print('Error fetching major information: $error');
    }
  }

  Future<void> _showMajorSelectionDialog(int fieldNumber) async {
    await _fetchMajors(); // 전공 리스트 가져오기

    String? newselectedMajor;  //새로 선택할 전공
    switch (fieldNumber) {
      case 1:
        newselectedMajor = _selectedMajor1; // 새로운 전공 저장
        _major1changed++;
        break;
      case 2:
        newselectedMajor = _selectedMajor2;
        break;
      case 3:
        newselectedMajor = _selectedMajor3;
        break;
      default:
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('전공을 선택해주세요.'),
          content: DropdownButton<String>(
            value: newselectedMajor,
            items: _majors.map((String major) {
              return DropdownMenuItem<String>(
                value: major,
                child: Text(major),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                switch (fieldNumber) {
                  case 1:
                    _selectedMajor1 = value!; // 선택된 전공을 저장
                    break;
                  case 2:
                    _selectedMajor2 = value;
                    break;
                  case 3:
                    _selectedMajor3 = value;
                    break;
                  default:
                }
              });
              Navigator.of(context).pop(); // Dialog 닫기
            },
          ),
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImageController.text = image.path;
      });
    }
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

  Widget _gap() => const SizedBox(height: 14);
}
