import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'dart:convert';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String studyName;

  ChatRoomScreen({required this.roomId, required this.studyName});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  User? loggedInUser;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    _fetchChatHistory();
  }

  Future<void> _fetchChatHistory() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getchatroommessages'),
      body: {'roomId': widget.roomId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        messages = List<Map<String, dynamic>>.from(data['data']);
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final bool isMyMessage = messages[index]['sender_id'] == loggedInUser?.user_id;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isMyMessage ? Colors.blue : Colors.grey[300],
                            borderRadius: isMyMessage
                                ? BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            )
                                : BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMyMessage) // 다른 사용자의 메시지인 경우에만 닉네임 표시
                                Text(
                                  messages[index]['nickname'],
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              SizedBox(height: 4), // 닉네임과 메시지 사이 간격 조정
                              Text(
                                messages[index]['content'],
                                style: TextStyle(
                                  color: isMyMessage ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          /*
        // 채팅 입력창 관련 코드 (주석 처리)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // Send message logic here
                  //_sendMessage();
                },
              ),
            ],
          ),
        ),
        */
        ],
      ),
    );
  }


}
