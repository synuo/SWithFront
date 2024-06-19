import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common_object.dart';
import 'home.dart';

class AddAQScreen extends StatefulWidget {
  final int post_id;

  const AddAQScreen({Key? key, required this.post_id}) : super(key: key);

  @override
  _AddAQScreenState createState() => _AddAQScreenState();
}

class _AddAQScreenState extends State<AddAQScreen> {
  List<TextEditingController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    User? loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    final user_id = loggedInUser?.user_id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '사전 질문 작성',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._controllers.map((controller) {
                int index = _controllers.indexOf(controller);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      title: '사전질문 ${index + 1}',
                      controller: controller,
                    ),
                    SizedBox(height: 12),
                  ],
                );
              }).toList(),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _controllers.add(TextEditingController());
                  });
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('사전질문 추가', style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xff4CAF50)), // 초록색 배경
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // 둥근 모서리
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // 버튼 내부 패딩
                  ),
                  elevation: MaterialStateProperty.all<double>(5.0), // 버튼 그림자
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showConfirmationDialog(user_id),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xff19A7CE)), // 버튼 배경색
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // 버튼 모서리 둥글기 설정
                    ),
                  ),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: EdgeInsets.symmetric(vertical: 15.0), // 버튼 내부 패딩
                  child: Center(
                    child: Text(
                      '등록 완료',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addAdvanceQ() async {
    final url = Uri.parse('http://localhost:3000/addadvance_q');
    final aqContentList = _controllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .toList();
    final aqIdList =
        List<int>.generate(aqContentList.length, (index) => index + 1);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'post_id': widget.post_id,
        'aq_id': aqIdList.isNotEmpty ? aqIdList : null,
        'aq_content': aqContentList.isNotEmpty ? aqContentList : null,
      }),
    );
    if (response.statusCode == 201) {
      print("사전질문 등록 완료");
    } else {
      throw Exception('사전질문 등록 실패');
    }
  }

  void _showConfirmationDialog(int? user_id) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '사전질문은 추후 수정할 수 없습니다.\n다시 한 번 내용을 검토하고 등록해주세요.',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      '취소',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      '등록',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      addAdvanceQ();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(user_id: user_id!),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String title,
    String? hintText,
    required TextEditingController controller,
    bool isMultiline = false,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (description != null) // Render description if provided
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: isMultiline ? null : 1,
            minLines: isMultiline ? 5 : 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }
}
