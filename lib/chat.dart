import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    fetchData();
    initializeSocket();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getchatrooms'),
      body: {'userId': loggedInUser?.user_id.toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        chatRooms = List<Map<String, dynamic>>.from(data['data']);
      });
    } else {
      print('Failed to load data');
    }
  }

  void initializeSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('connected');
    });

    socket.on('newMessage', (data) {
      setState(() {
        final updatedRoom = chatRooms.firstWhere((room) => room['room_id'] == data['room_id']);
        updatedRoom['last_message'] = data['last_message'];
        updatedRoom['last_message_time'] = data['last_message_time'];
        chatRooms.sort((a, b) {
          final timeA = a['last_message_time'] != null ? DateTime.parse(a['last_message_time']) : DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b['last_message_time'] != null ? DateTime.parse(b['last_message_time']) : DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA);
        });
      });
    });

    socket.onDisconnect((_) => print('disconnected'));
  }

  String formatMessageTimestamp(String timestamp) {
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
        title: Text('채팅'),
      ),
      body: chatRooms.isEmpty
          ? Center(child: Text('현재 가입한 스터디가 없습니다.'))
          : ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final lastMessage = chatRooms[index]['last_message'];
          final lastMessageTime = chatRooms[index]['last_message_time'];
          return Card(
            child: ListTile(
              title: Text(chatRooms[index]['study_name']),
              subtitle: lastMessage != null && lastMessageTime != null
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(lastMessage, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    formatMessageTimestamp(lastMessageTime),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      roomId: chatRooms[index]['room_id'].toString(),
                      studyName: chatRooms[index]['study_name'],
                    ),
                  ),
                );
              },
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
