import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'common_object.dart';
import 'home.dart';

//원형 버튼
class CircularButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CircularButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff94BDF2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

//하단 탭바
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: '게시판',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded),
          label: '채팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: '마이페이지',
        ),
      ],
    );
  }
}


//검색 바
class Search extends StatefulWidget {

  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String? inputText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(
                  builder: (context, controller) {
                    return SearchBar(
                      hintText: '글 제목, 내용, 해시태그 등을 입력해보세요.',
                      trailing: [Icon(Icons.search_outlined)],
                      controller: controller,
                      onTap: () => controller.openView(),
                      onChanged: (_) => controller.openView(),
                      onSubmitted: (value) {
                        setState(() {
                          inputText = value;
                        });
                      },
                    );
                  },
                  suggestionsBuilder: (context, controller) {
                    return [
                      ListTile(
                        title: const Text("추천검색어1"),
                        onTap: () {
                          setState(() => controller.closeView("추천검색어1"));
                        },
                      ),
                      ListTile(
                        title: const Text("추천검색어2"),
                        onTap: () {
                          setState(() => controller.closeView("추천검색어2"));
                        },
                      ),
                    ];
                  },
                ),
              ),
              Text("Input Text = $inputText", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}


class SearchField extends SearchDelegate{

  List <String> listof = ['스터디', '눈송', '공모전', '22학번', '모집중'];

  //텍스트필드 우측 위젯
  @override
  List<Widget> buildActions(BuildContext context){
    return [   //x버튼 누르면 입력한 검색어 지움
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){query = '';},
      )
    ];

  }

  //텍스트필트 좌측 위젯
  @override
  Widget buildLeading(BuildContext context){
    return IconButton(   //뒤로가기 기능
      icon: Icon(Icons.arrow_back),
      onPressed : (){
        //Navigator.pop(context);
        close(context, null);
      }
    );
  }

  @override
  Widget buildResults(BuildContext context){
    List<String> matchQuery = [];
    for (var fruit in listof){
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
        itemBuilder: (context, index){
          var result = matchQuery[index];
          return ListTile(
            title : Text(result),
          );
        },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context){
    List<String> matchQuery = [];
    for (var fruit in listof) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}



