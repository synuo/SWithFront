import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'common_object.dart';
import 'package:intl/intl.dart';
import 'otherprofile.dart';
import 'profile.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String studyName;
  final IO.Socket socket;

  ChatRoomScreen({required this.roomId, required this.studyName, required this.socket});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  User? loggedInUser;
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> members = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _messageLimit = 20;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser; // 현재 로그인된 유저 정보
    _initializeSocket(); // 소켓 초기화
    _scrollController.addListener(_scrollListener); // 스크롤할 때마다 _scrollListener 호출
  }

  void _initializeSocket() {
    widget.socket.on('chatHistory', _onChatHistory); // 채팅 내역 불러오기
    widget.socket.on('chatMessage', _onChatMessage); // 실시간으로 새로운 메시지 수신
    widget.socket.emit('joinRoom', widget.roomId); // 방 입장
    //_fetchChatHistory(); // 채팅 내역 불러오기
  }

  void _onChatMessage(data) {
    print('Received new message: ${data['content']}');
    setState(() {
      messages.insert(0, data); // 리스트 맨 앞에 새로운 메시지 삽입
    });
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onChatHistory(data) {
    final newMessages = List<Map<String, dynamic>>.from(data['data']);
    setState(() {
      if (newMessages.length < _messageLimit) {
        _hasMoreMessages = false;
      }
      messages.addAll(newMessages.reversed); // 시간 순서대로 추가
    });
    _isLoadingMore = false;
  }

  Future<void> _fetchChatHistory() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;
    final lastMessageTime = messages.isNotEmpty ? messages.last['chat_time'] : null;

    widget.socket.emit('getChatHistory', {
      'roomId': widget.roomId,
      'limit': _messageLimit,
      'lastMessageTime': lastMessageTime,
    });
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
      _fetchChatHistory();
    }
  }

  void _sendMessage() { //새로운 메시지 전송 버튼 누르면 호출
    if (_controller.text.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      final message = {
        'roomId': widget.roomId,
        'sender_id': loggedInUser?.user_id,
        'content': _controller.text,
        'chat_time': now,
      };
      widget.socket.emit('chatMessage', message);//서버로 메시지 데이터 전송
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

  Future<void> _fetchMembers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getchatroommembers/${widget.roomId}'));

    if (response.statusCode == 200) {
      setState(() {
        members = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      // 오류 처리
      throw Exception('Failed to load members');
    }
  }

  void _showMemberList() async {
    await _fetchMembers();
    bool isOwner = await _checkIfOwner(); // 방장 여부 확인 함수

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Members',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ...members.map((member) {
                bool isMe = member['member_id'] == loggedInUser?.user_id;
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person, size: 32),
                    radius: 16,
                  ),
                  title: Text(member['nickname']),
                  trailing: isOwner && !isMe
                      ? IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      _showKickMemberOptions(member['member_id'], member['nickname']);
                    },
                  )
                      : isMe
                      ? CircleAvatar(
                    child: Text('나'),
                    radius: 16,
                  )
                      : null,
                  onTap: () {
                    if (isMe) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(), // 나의 프로필 페이지로 이동
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(senderId: member['member_id']),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _showLeaveRoomDialog(),
                child: Text('나가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // 버튼 색상
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _checkIfOwner() async {
    // 방장 여부를 백엔드에서 확인하는 로직을 구현합니다.
    final response = await http.post(
      Uri.parse('http://localhost:3000/checkhost'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'roomId': widget.roomId,
        'memberId': loggedInUser?.user_id,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['isOwner'] as bool;
    } else {
      // 요청 실패 처리
      print('Failed to check owner status');
      return false;
    }
  }

  void _showKickMemberOptions(int memberId, String nickname) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListTile(
          title: Text('내보내기'),
          onTap: () {
            Navigator.pop(context); // Close the bottom sheet
            _showKickMemberConfirmation(memberId, nickname);
          },
        );
      },
    );
  }

  void _showKickMemberConfirmation(int memberId, String nickname) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사용자 내보내기'),
          content: Text('$nickname 님을 내보내시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _kickMember(memberId);
                Navigator.of(context).pop();
              },
              child: Text('내보내기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _kickMember(int memberId) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/leaveroom'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'roomId': widget.roomId,
        'memberId': memberId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        members.removeWhere((member) => member['member_id'] == memberId);
      });
      _showDialog('멤버를 내보냈습니다.');
    } else {
      // 오류 처리
      _showDialog('멤버 내보내기에 실패했습니다.');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }


  void _showLeaveRoomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('나가기'),
          content: Text('이 채팅방을 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveRoom();
              },
              child: Text('나가기'),
            ),
          ],
        );
      },
    );
  }

  void _leaveRoom() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/leaveroom'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'roomId': widget.roomId,
        'memberId': loggedInUser?.user_id,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      // 오류 처리
      throw Exception('Failed to leave room');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyName),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: _showMemberList,
          ),
        ],
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
                          if (!isMyMessage)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(senderId: messages[index]['sender_id']),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.person, size: 32),
                                radius: 16,
                              ),
                            ),
                          if (!isMyMessage)
                            SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: isMyMessage ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: isMyMessage ? Radius.circular(8.0) : Radius.zero,
                                    bottomLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                    bottomRight: isMyMessage ? Radius.zero : Radius.circular(8.0),
                                  ),
                                ),
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: isMyMessage ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMyMessage)
                                      Text(
                                        messages[index]['nickname'],
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (!isMyMessage)
                                      SizedBox(height: 4),
                                    Text(
                                      messages[index]['content'],
                                      style: TextStyle(
                                        color: isMyMessage ? Colors.white : Colors.black,
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
    widget.socket.emit('leaveRoom', widget.roomId);
    widget.socket.off('chatMessage', _onChatMessage);
    widget.socket.off('chatHistory', _onChatHistory);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
