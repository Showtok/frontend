import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:showtok/constants/api_config.dart';
import 'dart:io';

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
  XFile? _selectedImage;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
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
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('이미지 추가'),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: 서버로 전송
                },
                child: const Text('작성하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
