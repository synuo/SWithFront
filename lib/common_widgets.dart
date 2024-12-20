import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice/post_detail.dart';
import 'dart:io';
import 'common_object.dart';

//원형 버튼
class CircularButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const CircularButton({
    required this.text,
    required this.icon,
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
          color: Theme.of(context).colorScheme.primary
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              //SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
            ],
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
        selectedItemColor: Color(0xff19A7CE), // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        //backgroundColor: Colors.lightBlueAccent // Background color of the BottomNavigationBar
    );
  }
}

// 검색 바 : 현재 제목, 카테고리, 내용 감지함.
class Search extends StatefulWidget {
  final Function(String) onSearch;

  const Search({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  List<Post> _suggestions = [];   //검색어에 맞게 정렬

  Future<void> _fetchSuggestions(String query) async {
    final url = Uri.parse('http://localhost:3000/searchposts?query=$query');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _suggestions = jsonData.map((data) {
          return Post.fromJson(data);
        }).toList();
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

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
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '글 제목, 내용, 해시태그 등으로 검색해보세요.',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search_outlined),
                      onPressed: () {
                        widget.onSearch(_controller.text);
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _fetchSuggestions(value);
                    } else {
                      setState(() {
                        _suggestions = [];
                      });
                    }
                  },
                  onSubmitted: (value) {
                    widget.onSearch(value);
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion.title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(post_id: suggestion.post_id),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String? _pickedFile;

  @override
  Widget build(BuildContext context) {
    final _imageSize = MediaQuery.of(context).size.width / 4;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Example1'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20,),
            if (_pickedFile == null)
              Container(
                constraints: BoxConstraints(
                  minHeight: _imageSize,
                  minWidth: _imageSize,
                ),
                child: GestureDetector(
                  onTap: () {
                    _showBottomSheet();
                  },
                  child: Center(
                    child: Icon(
                      Icons.account_circle,
                      size: _imageSize,
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  width: _imageSize,
                  height: _imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2, color: Theme.of(context).colorScheme.primary),
                    image: DecorationImage(
                        image: FileImage(File(_pickedFile!)),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _showBottomSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _getCameraImage(),
              child: const Text('사진찍기'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => _getPhotoLibraryImage(),
              child: const Text('라이브러리에서 불러오기'),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  _getCameraImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await cropImage(pickedFile);
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  _getPhotoLibraryImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = _pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  Future<void> cropImage(XFile? filePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath!.path,
      maxWidth: 1080,
      maxHeight: 1080,
      aspectRatioPresets: Platform.isAndroid
          ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ]
          : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        )
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _pickedFile = croppedFile.path;
      });
    }
  }

}


