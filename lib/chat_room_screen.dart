import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'package:intl/intl.dart';

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
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser; //현재 로그인된 유저 정보
    _initializeSocket(); //소켓 초기화
    _scrollController.addListener(_scrollListener); //스크롤할 때마다 _scrollListener 호출
  }

  void _initializeSocket() { //소켓 초기화
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('connected');
      socket.emit('joinRoom', widget.roomId); //방 입장
      _fetchChatHistory(); //채팅 내역 불러오기
    });

    socket.on('chatMessage', (data) { // 실시간으로 새로운 메시지 수신. 서버에 새로운 메시지가 도착하면 이 콜백 함수 호출
      setState(() { // 상태 업데이트
        messages.insert(0, data); // 리스트 맨앞에 새로운 메시지 삽입
      });
      _scrollController.animateTo( //최신 메시지 볼 수 있도록 맨 위로 스크롤
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    socket.on('chatHistory', (data) { // 과거의 채팅기록 수신._fetchChatHistory()에서 요청하고,  서버에서 과거 채팅 기록 데이터를 보내주면 이 콜백 함수가 호출됨
      final newMessages = List<Map<String, dynamic>>.from(data['data']);
      setState(() {
        if (newMessages.length < _messageLimit) {
          _hasMoreMessages = false;
        }
        messages.addAll(newMessages.reversed); // 시간 순서대로 추가
      });
      _isLoadingMore = false;
    });

    socket.onDisconnect((_) => print('disconnected'));
  }

  Future<void> _fetchChatHistory() async { // 서버에 과거 메시지 요청
    if (_isLoadingMore || !_hasMoreMessages) return; //로딩중이거나 더이상 불러올 메시지가 없다면 바로 반환

    _isLoadingMore = true; //현재 메시지 불러오는 중
    final lastMessageTime = messages.isNotEmpty ? messages.last['chat_time'] : null; // 불러온 메시지 중 가장 과거 메시지의 시간

    socket.emit('getChatHistory', {
      'roomId': widget.roomId, // 방 ID
      'limit': _messageLimit, // 20
      'lastMessageTime': lastMessageTime, // 그 이후 시간 메시지 요청
    });
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) { // 스크롤이 리스트의 끝에 있을 때
      _fetchChatHistory(); //서버에 과거 메시지 요청
    }
  }

  void _sendMessage() { // 새로운 메시지 전송
    if (_controller.text.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      final message = {
        'roomId': widget.roomId,
        'sender_id': loggedInUser?.user_id,
        'content': _controller.text,
        'chat_time': now,
      };
      socket.emit('chatMessage', message); //서버로 메시지 전송
      _controller.clear(); //입력창 초기화
      _scrollController.animateTo( //맨 위로 스크롤하여 최신 메시지 표시
        0.0, //스크롤 위치를 0으로(맨위)
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
                                      Text(
                                        messages[index]['nickname'],
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
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
