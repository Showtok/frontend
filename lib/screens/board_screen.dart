
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/constants/api_config.dart';
import 'package:showtok/screens/guest_profile_screen.dart';
import 'package:showtok/screens/profile_screen.dart';
import 'package:showtok/screens/main_screen.dart';
import 'package:showtok/screens/post_create_screen.dart';
import 'package:showtok/screens/post_detail_screen.dart';
import 'package:showtok/utils/auth_util.dart';

import 'message_screen.dart';

class BoardScreen extends StatefulWidget {
  final String? initialKeyword;
  final String? initialLevel;
  final String? initialCategory;
  final String? initialPostCategory;

  const BoardScreen({
    super.key,
    this.initialKeyword,
    this.initialLevel,
    this.initialCategory,
    this.initialPostCategory,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String selectedLevel = 'ALL';
  String selectedCategory = 'ALL';
  String keyword = '';
  String postCategory = 'FREE';
  List<Map<String, dynamic>> posts = [];

  final levelMap = {
    'ALL': '전체',
    'BEGINNER': '초급',
    'INTERMEDIATE': '중급',
    'ADVANCED': '고급'
  };

  final categoryMap = {
    'DRAWING': '그림',
    'CODING': '코딩',
    'HOMEWORK': '과제',
    'MUSIC': '음악',
    'WRITING': '글쓰기',
    'PHOTO_VIDEO': '영상',
    'FASHION': '패션',
    'ALL': '전체',
  };

  @override
  void initState() {
    super.initState();
    keyword = widget.initialKeyword ?? '';
    selectedLevel = widget.initialLevel ?? 'ALL';
    selectedCategory = widget.initialCategory ?? 'ALL';
    postCategory = widget.initialPostCategory ?? 'FREE';
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/posts/search').replace(
      queryParameters: {
        'level': selectedLevel == 'ALL' ? '' : selectedLevel,
        'category': selectedCategory == 'ALL' ? '' : selectedCategory,
        'postCategory': postCategory,
        'keyword': keyword,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Map<String, dynamic>> loadedPosts = [];

      for (final post in data) {
        final likeRes = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/posts/${post['id']}/likes'),
        );

        final likeCount = likeRes.statusCode == 200 ? int.tryParse(likeRes.body) ?? 0 : 0;
        loadedPosts.add({...post, 'likeCount': likeCount});
      }

      setState(() {
        posts = loadedPosts;
      });
    } else {
      print('게시글 불러오기 실패: ${response.statusCode}');
    }
  }

  Widget _buildTab(String label, String value) {
    final isSelected = postCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          postCategory = value;
        });
        _fetchPosts();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Container(width: 20, height: 2, color: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('게시판', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔎 필터 바
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    value: selectedLevel,
                    onChanged: (value) {
                      setState(() => selectedLevel = value!);
                      _fetchPosts();
                    },
                    items: levelMap.keys.map((e) {
                      return DropdownMenuItem(value: e, child: Text(levelMap[e]!));
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                      _fetchPosts();
                    },
                    items: categoryMap.keys.map((e) {
                      return DropdownMenuItem(value: e, child: Text(categoryMap[e]!));
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '검색어',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => keyword = value,
                    onSubmitted: (_) => _fetchPosts(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔘 탭 + 글쓰기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTab('자유', 'FREE'),
                    _buildTab('정보', 'INFO'),
                    _buildTab('질문', 'QUESTION'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PostCreateScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('글쓰기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📄 게시글 목록
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (_, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PostDetailScreen(postId: post['id'])),
                        );
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(post['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up_alt_outlined, size: 14),
                              const SizedBox(width: 2),
                              Text('${post['likeCount']}'),
                              const SizedBox(width: 8),
                              const Icon(Icons.comment_outlined, size: 14),
                              const SizedBox(width: 2),
                              Text('${post['commentCount']}'),
                              const SizedBox(width: 8),
                              const Icon(Icons.remove_red_eye_outlined, size: 14),
                              const SizedBox(width: 2),
                              Text('${post['viewCount']}'),
                            ],
                          )
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Text('레벨: ${levelMap[post['level']]}'),
                            const SizedBox(width: 12),
                            Text('카테고리: ${categoryMap[post['category']]}'),
                            const SizedBox(width: 12),
                            Text('작성자: ${post['authorNickname']}'),
                          ],
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ⬇️ 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '쪽지'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '게시판'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
        ],
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessageScreen()),
            );
          } else if (index == 2) {
            // 현재 게시판 화면이므로 이동 없음
          } else if (index == 3) {
            final loggedIn = await AuthUtil.isLoggedIn();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => loggedIn
                    ? const ProfileScreen()
                    : const GuestProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
