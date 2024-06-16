import 'dart:convert';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스터디 멤버'),
      ),
      body: members.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: member['user_image'] != null
                  ? NetworkImage(member['user_image'])
                  : null,
              child: member['user_image'] == null
                  ? Icon(Icons.account_circle)
                  : null,
            ),
            title: Text(member['nickname']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(senderId: member['user_id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
