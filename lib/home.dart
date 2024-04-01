import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; //검색 바에서 입력된 검색어를 저장하는 변수. 검색 쿼리
  bool _isAuth = false;

  @override
  void didChangeDependencies() async{
    final token = await SharedPreferManager().getSharedPreferences();
    if (token != "Not Auth"){
      _isAuth = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Home'),
        actions: [
          //IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          //IconButton(icon: Icon(Icons.search), onPressed: () {}),
          //IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          _buildSearchButton(),
          _buildNotificationButton(),
          _buildMenuButton(),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularButton(context, '스터디'),
              _buildCircularButton(context, '공모전'),
              _buildCircularButton(context, '기타'),
            ],
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 글',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // 여기에 AI 기능을 통해 추천된 글을 나타내는 위젯 넣기
              ],
            ),
          )
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '홈',
          ),
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
  Widget _buildSearchButton() {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        print('Search button clicked');
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "사용자 인증에 성공했습니다.",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "로그인을 진행해주세요.",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class SharedPreferManager{
  static final SharedPreferManager _instance = SharedPreferManager._internal();
  final Future <SharedPreferences> _manager = SharedPreferences.getInstance();

  SharedPreferManager._internal(){}

  factory SharedPreferManager(){
    return _instance;
  }

  Future <void> setSharedPreference(String token) async{
    final manager = await _manager;
  }

  Future <String> getSharedPreferences() async{
    final manager = await _manager;
    return manager.getString("auth")??"Not Auth";
  }

  getString(String s) {}

}


