import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/profile.dart';
import 'package:provider/provider.dart';
import 'Applicants.dart';
import 'common_object.dart';
import 'otherprofile.dart';
import 'editpost.dart';
import 'advance_a.dart';

class PostDetailScreen extends StatefulWidget {
  final int post_id;

  const PostDetailScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isScrapped = false;
  bool isApplied = false;
  bool isActive = false;
  User? loggedInUser;
  late TabController _tabController;
  List<Map<String, dynamic>> questions = [];
  String newQuestion = '';
  Map<int, String> newAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
      if (loggedInUser != null) {
        getScrap();
        checkApplicationStatus();
      }
    });
    fetchQuestions();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<Post> fetchPostDetails(int postId) async {
    final url = Uri.parse('http://localhost:3000/getposts/$postId');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final data = jsonData.isNotEmpty ? jsonData.first : null;
      if (data == null) {
        throw Exception('Post not found');
      }
      return Post.fromJson(data);
    } else {
      throw Exception('Failed to load post detail');
    }
  }

  Future<void> getScrap() async {
    final url =
        Uri.parse('http://localhost:3000/getscrap').replace(queryParameters: {
      'user_id': loggedInUser?.user_id.toString(),
      'post_id': widget.post_id.toString(),
    });

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        isScrapped = responseData['isScrapped'] == 1;
      });
    } else {
      throw Exception('Failed to get scrap status');
    }
  }

  Future<void> addScrap() async {
    final url = Uri.parse('http://localhost:3000/addscrap');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 201) {
      print("Scrap added successfully");
    } else {
      throw Exception('Failed to add scrap');
    }
  }

  Future<void> deleteScrap() async {
    final url = Uri.parse('http://localhost:3000/deletescrap');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 200) {
      print("Scrap removed successfully");
    } else {
      throw Exception('Failed to delete scrap');
    }
  }

  Future<void> checkApplicationStatus() async {
    final url = Uri.parse('http://localhost:3000/checkApplication');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        isApplied = responseData['isApplied'];
      });
    } else {
      // Handle the error
      setState(() {
        isApplied = false;
      });
    }
  }

  Future<void> applyForPost() async {
    final url = Uri.parse('http://localhost:3000/getadvance_q')
        .replace(queryParameters: {
      'post_id': widget.post_id.toString(),
    });

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.length > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvanceAScreen(
                post_id: widget.post_id, advance_q: responseData),
          ),
        ).then((result) {
          if (result == true) {
            addApplication();
          }
        });
      } else {
        addApplication();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지원 완료')),
        );
      }
    } else {
      throw Exception('Failed to check advance_q status');
    }
  }

  Future<void> addApplication() async {
    final url = Uri.parse('http://localhost:3000/addapplication');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'applicant_id': loggedInUser?.user_id,
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 201) {
      print("Application added successfully");
    } else {
      throw Exception('Failed to add application');
    }
  }

  Future<void> patchProgress(String progress) async {
    final url = Uri.parse('http://localhost:3000/patchpostprogress');
    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post_id,
        'progress': progress,
      }),
    );
    if (response.statusCode == 200) {
      print("Progress updated successfully");
      setState(() {});
    } else {
      throw Exception('Failed to update progress');
    }
  }

  Future<void> createChatRoom() async {
    final url = Uri.parse('http://localhost:3000/newchatroom');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post_id,
      }),
    );
    if (response.statusCode == 200) {
      print("Chat room created successfully");
    } else {
      throw Exception('Failed to create chat room');
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('모집 상태 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('모집 종료'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmProgressChange('모집 종료');
                },
              ),
              ListTile(
                title: Text('추가 모집'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmProgressChange('추가 모집');
                },
              ),
              ListTile(
                title: Text('스터디 종료'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmProgressChange('스터디 종료');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmProgressChange(String progress) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('정말 $progress 하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.of(context).pop();
                patchProgress(progress);
                createChatRoom();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchQuestions() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/getquestions/${widget.post_id}'));
    if (response.statusCode == 200) {
      setState(() {
        questions = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<void> addQuestion() async {
    if (newQuestion.trim().isEmpty) return;
    final response = await http.post(
      Uri.parse('http://localhost:3000/addquestion/${widget.post_id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'questioner_id': loggedInUser?.user_id,
        'question': newQuestion,
      }),
    );
    if (response.statusCode == 201) {
      fetchQuestions();
      setState(() {
        newQuestion = '';
      });
    } else {
      throw Exception('Failed to add question');
    }
  }

  Future<void> addAnswer(int questionId, String answer) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/addanswer/${questionId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'answer': answer,
      }),
    );
    if (response.statusCode == 201) {
      fetchQuestions();
    } else {
      throw Exception('Failed to add answer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post>(
      future: fetchPostDetails(widget.post_id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              elevation: 0.0,
              backgroundColor: Color(0xff19A7CE),
              centerTitle: true,
              actions: [],
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final post = snapshot.data!;
          bool isWriter =
              loggedInUser != null && post.writer_id == loggedInUser!.user_id;
          if (post.progress == '모집중' || post.progress == '추가 모집') {
            isActive = true;
          }

          return Scaffold(
            appBar: AppBar(
              actions: [
                if (isWriter)
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'update':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditPostScreen(post: post)),
                          ).then((_) {
                            fetchPostDetails(widget.post_id);
                            fetchQuestions();
                          });
                          break;
                        case 'change_progress':
                          _showProgressDialog();
                          break;
                        case 'check_applicants':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ApplicantsScreen(post_id: widget.post_id)),
                          );
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'update',
                        child: Text('게시글 수정'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'change_progress',
                        child: Text('모집 상태 변경'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'check_applicants',
                        child: Text('지원자 확인'),
                      ),
                    ],
                  ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xff19A7CE),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.zero,
                              topRight: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            post.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          if (isWriter) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen()), // 본인 프로필 화면으로 이동
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                      senderId:
                                          post.writer_id)), // 글 작성자 프로필 화면으로 이동
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.writer_image != null)
                              Image.network(
                                Uri.encodeFull(post.writer_image!),
                                width: 50,
                                height: 50,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  print('Error loading image: $exception');
                                  return Icon(
                                    Icons.account_circle,
                                    size: 50,
                                  );
                                },
                              )
                            else
                              Icon(
                                Icons.account_circle,
                                size: 50,
                              ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.writer_nickname ?? '닉네임 로드 실패',
                                    // 닉네임 표시
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${post.writer_student_id}학번 | " ??
                                            '학번 로드 실패',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        '${post.writer_major1}', // 전공1 표시
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '카테고리: ${post.category}',
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '조회수: ${post.view_count}',
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '작성일: ${post.create_at.toString().substring(0, 10)}',
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: post.tags
                            .map((tag) => Text(
                          '#$tag',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14.0),
                        ))
                            .toList(),
                      ),
                    ],
                  ),

                ),Container(
                  height: kToolbarHeight + 2.0,
                  padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontSize: 16.0, // Adjust the font size for the selected tab
                      fontWeight: FontWeight.bold, // Adjust the font weight for the selected tab
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16.0, // Adjust the font size for the unselected tabs
                      fontWeight: FontWeight.bold, // Adjust the font weight for the unselected tabs
                    ),
                    tabs: [
                      Tab(text: '상     세'),
                      Tab(text: 'Q  &  A'),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${post.content}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: questions.length,
                                itemBuilder: (context, index) {
                                  final question = questions[index];
                                  final questionId = question['question_id'];
                                  final questionText = question['question'];
                                  final answerText = question['answer'] ?? '';
                                  final questionerId =
                                      question['questioner_id']; // 질문자의 ID

                                  return Card(
                                    color: Colors.white,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Q: $questionText',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              if (answerText.isNotEmpty)
                                                Text('A: $answerText')
                                              else if (isWriter)
                                                Column(
                                                  children: [
                                                    TextField(
                                                      onChanged: (text) {
                                                        newAnswers[questionId] =
                                                            text;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            '답변을 기다리고 있어요!',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () {
                                                          if (newAnswers
                                                              .containsKey(
                                                                  questionId)) {
                                                            addAnswer(
                                                                questionId,
                                                                newAnswers[
                                                                    questionId]!);
                                                          }
                                                        },
                                                        icon: Icon(Icons.send),
                                                        label: Text(''),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (questionerId ==
                                                loggedInUser?.user_id &&
                                            answerText.isEmpty)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                print("질문 삭제");
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _tabController.index == 0 && !isWriter
                ? BottomAppBar(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            isScrapped ? Icons.bookmark : Icons.bookmark_border,
                            color: isScrapped
                                ? Color(0xff19A7CE)
                                : Color(0xff19A7CE),
                          ),
                          iconSize: 32, // 아이콘 크기 조정
                          onPressed: () {
                            if (loggedInUser != null) {
                              setState(() {
                                if (isScrapped) {
                                  deleteScrap();
                                } else {
                                  addScrap();
                                }
                                isScrapped = !isScrapped;
                              });
                            } else {
                              print("User is not logged in");
                            }
                          },
                        ),
                        SizedBox(
                            width: 10), // IconButton과 ElevatedButton 사이 간격 조정

                        ElevatedButton(
                          onPressed: () {
                            if (isApplied) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdvanceAnswersScreen(
                                    postId: widget.post_id,
                                    applicantId: loggedInUser!.user_id,
                                    nickname: loggedInUser!.nickname,
                                  ),
                                ),
                              );
                            } else {
                              if (isActive) {
                                applyForPost();
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              !isActive && !isApplied
                                  ? Colors.grey
                                  : Color(0xff19A7CE), // 버튼 배경색
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // 버튼 모서리 둥글기 설정
                              ),
                            ),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0), // 버튼 내부 패딩
                            child: Center(
                              child: Text(
                                !isActive && !isApplied
                                    ? "모집 마감"
                                    : (isApplied ? "지원 내역 보기" : '지원하기'),
                                style: TextStyle(
                                  color: !isActive && !isApplied
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _tabController.index == 1 && !isWriter
                    ? BottomAppBar(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (text) {
                                    newQuestion = text;
                                  },
                                  decoration: InputDecoration(
                                    hintText: '궁금한 점을 스터디장에게 물어보세요!',
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: addQuestion,
                                icon: Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
          );
        }
      },
    );
  }
}
