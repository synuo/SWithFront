import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice/home.dart';
import 'package:practice/mainhome.dart';
import 'package:practice/mypage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common_widgets.dart';
import 'package:practice/board.dart';
import 'package:practice/chat.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: '메인홈',
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
];

class _HomePage2State extends State<HomePage2> {
  int _selectedIndex = 0;
  String? inputText;

  final List<Widget> _pages = [
    mainhomescreen(),
    BoardScreen(),
    ChatScreen(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Main Home', style: TextStyle(color: Color(0xff19A7CE), fontSize: 20.0),),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          _buildNotificationButton(),
          _buildMenuButton(),
        ],
      ),
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
          items: _navBarItems,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          })
          : null,
      body: Row(
        children: <Widget>[
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: isLargeScreen,
              destinations: _navBarItems
                  .map((item) => NavigationRailDestination(
                  icon: item.icon,
                  selectedIcon: item.activeIcon,
                  label: Text(
                    item.label!,
                  )))
                  .toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Center(
              child: _pages[_selectedIndex], //해당 페이로 이동
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchButton(){
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor(
              builder: (context, controller) {
                return SearchBar(
                  trailing: [Icon(Icons.search)],
                  controller: controller,
                  onTap: () => controller.openView(),
                  onChanged: (_) => controller.openView(),
                  onSubmitted: (value) {
                    setState(() => inputText = value);
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
          Text("Input Text = $inputText", style: TextStyle(fontSize: 10))
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        print('Menu button clicked');
      },
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {
        print('Notification button clicked');
      },
    );
  }

  Widget _buildCircularButton(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        // 각 버튼을 눌렀을 때의 동작을 추가할 수 있습니다.
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
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
