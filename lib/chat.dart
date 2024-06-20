import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'common_object.dart';
import 'chat_room_screen.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> chatRooms = [];
  User? loggedInUser;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
    initializeSocket();
  }

  void initializeSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('connected');
      socket.emit('fetchChatRooms', {'userId': loggedInUser?.user_id.toString()}); // 채팅방 목록 데이터 요청
    });

    socket.on('chatRooms', (data) { // 채팅방 목록, 마지막 메시지 수신
      setState(() {
        chatRooms = List<Map<String, dynamic>>.from(data['data']);
        sortChatRooms();
      });
    });

    socket.on('newMessage', (data) {
      setState(() {
        int roomIndex = chatRooms.indexWhere((room) => room['room_id'].toString() == data['room_id'].toString());

        if (roomIndex != -1) {
          // 기존 채팅방 업데이트
          chatRooms[roomIndex] = {
            'room_id': data['room_id'],
            'study_name': data['study_name'],
            'last_message': data['last_message'],
            'last_message_time': data['last_message_time'],
          };
        } else { //없으면
          // 새로운 채팅방 추가
          chatRooms.add({
            'room_id': data['room_id'],
            'study_name': data['study_name'],
            'last_message': data['last_message'],
            'last_message_time': data['last_message_time'],
          });
        }
        sortChatRooms();
      });
    });

    socket.onDisconnect((_) => print('disconnected'));
  }

  void sortChatRooms() {
    chatRooms.sort((a, b) {
      final timeA = a['last_message_time'] != null ? DateTime.parse(a['last_message_time']) : DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b['last_message_time'] != null ? DateTime.parse(b['last_message_time']) : DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });
  }

  String formatMessageTimestamp(String? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final now = DateTime.now();
    final messageTime = DateTime.parse(timestamp).toLocal();

    if (now.year == messageTime.year && now.month == messageTime.month && now.day == messageTime.day) {
      return DateFormat('HH:mm').format(messageTime);
    } else {
      return DateFormat('yyyy-MM-dd').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나의 스터디', style: TextStyle(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),),
      ),
      body: chatRooms.isEmpty
          ? Center(child: Text('현재 가입한 스터디가 없습니다.'))
          : ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final lastMessage = chatRooms[index]['last_message'] as String?;
          final lastMessageTime = chatRooms[index]['last_message_time'] as String?;
          final studyName = chatRooms[index]['study_name'] as String;
          return Card(
            child: Container(
              color: Colors.white, // ListTile의 배경을 흰색으로 설정
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.group, size: 32, color: Colors.white), // Icons.group 아이콘 추가
                  backgroundColor: Color(0xff19A7CE), // CircleAvatar 배경색 설정
                  radius: 20,
                ),
                title: Text(
                  studyName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: lastMessage != null && lastMessageTime != null
                    ? Text(
                  lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                )
                    : null,
                trailing: lastMessageTime != null
                    ? Text(
                  formatMessageTimestamp(lastMessageTime),
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        roomId: chatRooms[index]['room_id'].toString(),
                        studyName: studyName,
                        socket: socket,
                      ),
                    ),
                  ).then((_) {
                    socket.emit('fetchChatRooms', {'userId': loggedInUser?.user_id.toString()});
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }



  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
