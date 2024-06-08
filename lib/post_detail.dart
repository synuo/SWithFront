import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/profile.dart';
import 'package:provider/provider.dart';
import 'Applicants.dart';
import 'common_object.dart';
import 'otherprofile.dart';
import 'updatepost.dart';
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
  User? loggedInUser;
  late TabController _tabController;
  List<Map<String, dynamic>> questions = [];
  String newQuestion = '';
  Map<int, String> newAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
      if (loggedInUser != null) {
        getScrap();
      }
    });
    fetchQuestions();
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

      return Post(
        post_id: data['post_id'] as int,
        title: data['title'] as String,
        category: data['category'] as String,
        view_count: data['view_count'] as int,
        progress: data['progress'] as String,
        writer_id: data['writer_id'] as int,
        writer_nickname: data['nickname'] as String,
        writer_student_id: data['student_id'].toString().substring(0, 2),
        writer_major1: data['major1'] as String,
        writer_image: data['user_image'] != null ? data['user_image'] as String : '',
        writer_major2: data['major2'] != null ? data['major2'] as String : '',
        writer_major3: data['major3'] != null ? data['major3'] as String : '',
        create_at: DateTime.parse(data['create_at']),
        update_at: DateTime.parse(data['update_at']),
        study_name: data['study_name'] as String,
        content: data['content'] as String,
      );
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

          return Scaffold(
            appBar: AppBar(
              title: Text(post.title),
              elevation: 0.0,
              centerTitle: true,
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
                                    UpdatePostScreen(post: post)),
                          );
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
                if (!isWriter)
                  IconButton(
                    icon: Icon(
                      isScrapped ? Icons.bookmark : Icons.bookmark_border,
                      color: isScrapped ? Colors.orange : Colors.white,
                    ),
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
                if (!isWriter)
                  TextButton(
                    onPressed: () {
                      if (loggedInUser != null) {
                        applyForPost();
                      } else {
                        print("User is not logged in");
                      }
                    },
                    child: Text(
                      '지원하기',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        '모집 현황: ${post.progress}',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Divider(
                  // 가로로 된 구분선
                  color: Colors.grey, // 구분선 색상 설정
                  height: 0, // 구분선의 높이 설정
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
                                senderId: post.writer_id)), // 글 작성자 프로필 화면으로 이동
                      );
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey, // 임시로 회색으로 지정
                        ),

                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              post.writer_nickname ?? '닉네임 로드 실패', // 닉네임 표시
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "${post.writer_student_id}학번" ?? '학번 로드 실패', // 학번 표시
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '전공1: ${post.writer_major1}', // 전공1 표시
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            if (post.writer_major2 != null)
                              Text(
                                '전공2: ${post.writer_major2}', // 전공2 표시
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            if (post.writer_major3 != null)
                              Text(
                                '전공3: ${post.writer_major3}', // 전공3 표시
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
                const SizedBox(height: 8),
                Divider(
                  // 가로로 된 구분선
                  color: Colors.grey, // 구분선 색상 설정
                  height: 0, // 구분선의 높이 설정
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '상세'),
                    Tab(text: 'Q&A'),
                  ],
                ),
                Divider(
                  color: Colors.grey,
                  height: 0,
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
                                                        labelText:
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
                            if (!isWriter)
                              Divider(
                                // 질문 추가 란과 Q&A Card 사이의 구분선
                                color: Colors.grey,
                                height: 1,
                              ),
                            if (!isWriter)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        onChanged: (text) {
                                          newQuestion = text;
                                        },
                                        decoration: InputDecoration(
                                          labelText: '궁금한 점을 스터디장에게 물어보세요!',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
