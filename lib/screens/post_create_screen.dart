import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:showtok/constants/api_config.dart';
import 'package:showtok/screens/board_screen.dart';
import 'package:showtok/utils/auth_util.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String selectedLevel = 'BEGINNER';
  String selectedCategory = 'DRAWING';
  String selectedPostCategory = 'FREE';
  List<XFile> _selectedImages = [];

  final levelMap = {
    'BEGINNER': '초급',
    'INTERMEDIATE': '중급',
    'ADVANCED': '고급',
  };

  final categoryMap = {
    'DRAWING': '그림',
    'CODING': '코딩',
    'HOMEWORK': '과제',
    'MUSIC': '음악',
    'WRITING': '글쓰기',
    'PHOTO_VIDEO': '영상',
    'FASHION': '패션',
  };

  final postCategoryMap = {
    'FREE': '자유',
    'INFO': '정보',
    'QUESTION': '질문',
  };

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages = picked;
      });
    }
  }

  Future<void> _submitPost() async {
    try {
      final token = await AuthUtil.getToken();
      if (token == null) throw Exception('로그인이 필요합니다.');

      List<String> imageUrls = [];

      for (XFile image in _selectedImages) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/api/files/upload'),
        );

        if (kIsWeb) {
          Uint8List bytes = await image.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: image.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            image.path,
          ));
        }

        final response = await request.send();
        if (response.statusCode == 200) {
          final resString = await response.stream.bytesToString();
          imageUrls.add(resString.replaceAll('"', ''));
        } else {
          throw Exception('이미지 업로드 실패');
        }
      }

      String contentWithImages = _contentController.text;
      for (String url in imageUrls) {
        contentWithImages += '\n\n![image]($url)';
      }

      final postData = {
        'title': _titleController.text,
        'content': contentWithImages,
        'category': selectedCategory,
        'postCategory': selectedPostCategory,
        'level': selectedLevel,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 성공적으로 등록되었습니다!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BoardScreen()),
              (route) => false,
        );
      } else {
        throw Exception('글 작성 실패: ${response.body}');
      }
    } catch (e) {
      print('에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('글 작성', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 드롭다운
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedLevel,
                      decoration: const InputDecoration(labelText: '레벨'),
                      items: levelMap.keys
                          .map((e) => DropdownMenuItem(value: e, child: Text(levelMap[e]!)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedLevel = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: '카테고리'),
                      items: categoryMap.keys
                          .map((e) => DropdownMenuItem(value: e, child: Text(categoryMap[e]!)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedPostCategory,
                      decoration: const InputDecoration(labelText: '분류'),
                      items: postCategoryMap.keys
                          .map((e) => DropdownMenuItem(value: e, child: Text(postCategoryMap[e]!)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedPostCategory = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 제목
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // 내용
              TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(labelText: '내용', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // 이미지 선택
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('이미지 추가 (여러 장 가능)'),
              ),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                          image.path,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          File(image.path),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // 작성 버튼
              ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('작성하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
