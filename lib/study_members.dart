import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'otherprofile.dart';

class StudyMembersScreen extends StatefulWidget {
  @override
  _StudyMembersScreenState createState() => _StudyMembersScreenState();
}

class _StudyMembersScreenState extends State<StudyMembersScreen> {
  List<Map<String, dynamic>> members = [];
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    fetchStudyMembers();
  }

  Future<void> fetchStudyMembers() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getstudymembers'),
      body: {'userId': loggedInUser?.user_id.toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        members = List<Map<String, dynamic>>.from(data['data']);
      });
    } else {
      print('Failed to load study members');
    }
  }

  void navigateToProfile(int senderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          senderId: senderId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '스터디 멤버',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // 선의 두께를 설정합니다.
          child: Container(
            color: Colors.black12, // 선의 색상을 설정합니다.
            height: 1.0, // 선의 높이를 설정합니다.
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final String? profileIconString = member['user_image'];
                    final int? profileIconCodePoint = profileIconString != null && profileIconString.isNotEmpty
                        ? int.tryParse(profileIconString)
                        : null;
                    return GestureDetector(
                      onTap: () {
                        navigateToProfile(member['user_id']);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff19A7CE)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                /*
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                  member['user_image'] != null &&
                                      member['user_image'].isNotEmpty
                                      ? NetworkImage(member['user_image'])
                                      : null,
                                  child: member['user_image'] == null ||
                                      member['user_image'].isEmpty
                                      ? Icon(Icons.person, size: 30)
                                      : null,
                                ),

                                 */
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                  child: profileIconCodePoint != null
                                      ? Icon(
                                    IconData(profileIconCodePoint, fontFamily: 'MaterialIcons'),
                                    size: 30,
                                    color: Color(0xff19A7CE),
                                  )
                                      : Icon(Icons.person, size: 30,color: Color(0xff19A7CE)),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['nickname'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${member['student_id']} 학번  |  ${member['major1']}, ${member['major2'] ?? '-'}, ${member['major3'] ?? '-'}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.inactiveGray),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),

          ],
        ),
      ),
    );
  }
}
