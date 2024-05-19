import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          label: '마이페이지',
        ),
      ],
    );
  }
}

class SearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SearchButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: onPressed,
    );
  }
}

class ContainerDropDown extends StatefulWidget {
  final List<String> items; // 선택할 수 있는 항목들의 목록
  final String hint; // null 값 일시 띄워줄 값

  const ContainerDropDown({
    Key? key,
    required this.items,
    required this.hint,
  }) : super(key: key);

  @override
  _ContainerDropDownState createState() => _ContainerDropDownState();
}

class _ContainerDropDownState extends State<ContainerDropDown> {
  String? selectedValue; // 현재 선택된 항목의 값
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(widget.hint),
              ),
              ...widget.items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}