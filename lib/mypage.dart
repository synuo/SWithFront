import 'package:flutter/material.dart';
import 'package:practice/editprofile.dart';
import 'package:practice/study_members.dart';
import 'package:provider/provider.dart';
import 'MyScrapsPage.dart';
import 'setting.dart';
import 'profile.dart';
import 'common_object.dart';
import 'MyPostsPage.dart';
import 'MyApplicationsPage.dart';
import 'editprofile.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    User? loggedInUser = Provider.of<UserProvider>(context).loggedInUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Icon(
                      IconData(loggedInUser?.user_image ?? Icons.person.codePoint, fontFamily: 'MaterialIcons'),
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          loggedInUser?.nickname ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xff19A7CE),
                          ),
                        ),
                        SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: loggedInUser?.name ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: loggedInUser?.student_id != null ? ' | ${loggedInUser!.student_id}' : '',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xff19A7CE),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                          );
                        },
                        icon: Icon(Icons.edit),
                        color: Color(0xff19A7CE),
                        iconSize: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(height: 1, color: Color(0xff19A7CE)),
            SizedBox(height: 5),
            buildMenuItem('나의 모집 내역', Icons.post_add, Color(0xff84b9c0), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPostsPage()),
              );
            }),
            SizedBox(height: 5),
            Divider(height: 1, color: Color(0xff19A7CE)),
            SizedBox(height: 5),
            buildMenuItem('나의 지원 내역', Icons.assignment_turned_in, Color(0xffe26559), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApplicationsPage()),
              );
            }),
            SizedBox(height: 5),
            Divider(height: 1, color: Color(0xff19A7CE)),
            SizedBox(height: 5),
            buildMenuItem('스크랩', Icons.bookmark, Color(0xffffe697), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyScrapsPage()),
              );
            }),
            SizedBox(height: 5),
            Divider(height: 1, color: Color(0xff19A7CE)),
            SizedBox(height: 5),
            buildMenuItem('나와 함께한 사람들', Icons.people, Color(0xff2b7799), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudyMembersScreen()),
              );
            }),
            SizedBox(height: 5),
            Divider(height: 1, color: Color(0xff19A7CE)),
            SizedBox(height: 5),
            buildMenuItem('설정', Icons.settings, Color(0xffc5d7f2), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            }),
            SizedBox(height: 5),
            Divider(height: 1, color: Color(0xff19A7CE)),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xff19A7CE),
            ),
          ],
        ),
      ),
    );
  }
}
