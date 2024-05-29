import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'package:intl/intl.dart';
import 'otherprofile.dart';

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
  late IO.Socket socket;
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _messageLimit = 20;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    _initializeSocket();
    _scrollController.addListener(_scrollListener);
  }

  void _initializeSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('connected');
      socket.emit('joinRoom', widget.roomId);
      _fetchChatHistory();
    });

    socket.on('chatMessage', (data) {
      setState(() {
        messages.insert(0, data);
      });
    });

    socket.onDisconnect((_) => print('disconnected'));
  }

  Future<void> _fetchChatHistory() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;
    final lastMessageTime = messages.isNotEmpty ? messages.last['chat_time'] : null;

    socket.emit('getChatHistory', {
      'roomId': widget.roomId,
      'limit': _messageLimit,
      'lastMessageTime': lastMessageTime,
    });

    socket.once('chatHistory', (data) {
      final newMessages = List<Map<String, dynamic>>.from(data['data']);
      setState(() {
        if (newMessages.length < _messageLimit) {
          _hasMoreMessages = false;
        }
        messages.addAll(newMessages.reversed);
      });
      _isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
      _fetchChatHistory();
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {

      final now = DateTime.now().toIso8601String();
      final message = {
        'roomId': widget.roomId,
        'sender_id': loggedInUser?.user_id,
        'nickname': loggedInUser?.nickname,
        'content': _controller.text,
        'chat_time': now,
      };
      socket.emit('chatMessage', message);
      _controller.clear();
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTimestamp(String timestamp) {

    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(String timestamp) {

    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('yyyy-MM-dd').format(dateTime);
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
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final bool isMyMessage = messages[index]['sender_id'] == loggedInUser?.user_id;
                final bool showDate = index == messages.length - 1 ||
                    _formatDate(messages[index]['chat_time']) !=
                        _formatDate(messages[index + 1]['chat_time']);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _formatDate(messages[index]['chat_time']),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment:
                        isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (isMyMessage)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      bottomLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        messages[index]['content'],
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                  child: Text(
                                    _formatTimestamp(messages[index]['chat_time']),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      bottomRight: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // 클릭한 닉네임에 해당하는 사용자 정보를 가져오는 로직을 구현해야 합니다.
                                          // 사용자 정보를 가져왔다고 가정하고, 프로필 화면으로 이동하는 예시 코드를 작성합니다.
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserProfileScreen(nickname: messages[index]['nickname']),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          messages[index]['nickname'],
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        messages[index]['content'],
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                                  child: Text(
                                    _formatTimestamp(messages[index]['chat_time']),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
