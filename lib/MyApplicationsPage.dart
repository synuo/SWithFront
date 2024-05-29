import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:practice/post_detail.dart';
import 'common_object.dart';

class MyApplicationsPage extends StatefulWidget {
  @override
  _MyApplicationsPageState createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<Application> userApplications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserApplications();
  }

  Future<void> fetchUserApplications() async {
    User? loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    final userId = loggedInUser?.user_id;
    final url = 'http://localhost:3000/userapplications/user/$userId/applications';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<Application> applications = (json.decode(response.body) as List)
            .map((data) => Application.fromJson(data))
            .toList();

        for (var application in applications) {
          await fetchPostDetails(application);
        }

        setState(() {
          userApplications = applications;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (error) {
      print('Error fetching user applications: $error');
    }
  }

  Future<void> fetchPostDetails(Application application) async {
    final url = 'http://localhost:3000/userposts/user/${application.postId}/posts';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> postDetails = json.decode(response.body);
        if (postDetails.isNotEmpty) {
          application.updatePostInfo(postDetails[0]);
        }
      } else {
        throw Exception('Failed to load post details');
      }
    } catch (error) {
      print('Error fetching post details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나의 지원 내역'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Provider.of<UserProvider>(context).loggedInUser?.nickname ?? ''} 님의 지원 내역',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: userApplications.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_getCategoryIcon(userApplications[index].category ?? '')),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userApplications[index].title ?? '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userApplications[index].studyName ?? '',
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                userApplications[index].status ?? '',
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to the post detail screen with the postId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                              post_id: userApplications[index].postId,
                            ),
                          ),
                        );
                      },
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '스터디':
        return Icons.book;
      case '공모전':
        return Icons.emoji_events;
      default:
        return Icons.category;
    }
  }
}
