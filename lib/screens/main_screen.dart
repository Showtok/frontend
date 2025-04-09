
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/screens/profile_screen.dart';
import 'package:showtok/screens/guest_profile_screen.dart';
import 'package:showtok/screens/settings_screen.dart';
import 'package:showtok/screens/board_screen.dart';
import 'package:showtok/screens/message_screen.dart';
import 'package:showtok/screens/post_detail_screen.dart';
import 'package:showtok/utils/auth_util.dart';
import 'package:showtok/constants/api_config.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> popularPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchPopularPosts();
  }

  Future<void> _fetchPopularPosts() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/posts/popular'),
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));

        final List<Map<String, dynamic>> loadedPosts = [];
        for (final e in data) {
          final likeRes = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/posts/${e['id']}/likes'),
          );
          final likeCount = likeRes.statusCode == 200 ? int.tryParse(likeRes.body) ?? 0 : 0;

          loadedPosts.add({
            'id': e['id'],
            'title': e['title'],
            'category': _convertCategoryToKorean(e['category']),
            'likeCount': likeCount,
            'commentCount': e['commentCount'] ?? 0,
          });
        }

        setState(() {
          popularPosts = loadedPosts;
        });
      } else {
        print('🔥 서버 응답 에러: ${res.statusCode}');
      }
    } catch (e) {
      print('🔥 인기글 로딩 오류: $e');
    }
  }

  void _onCategoryTap(String label) {
    final keyword = label.split(" / ").first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BoardScreen(
          initialKeyword: keyword,
          initialLevel: 'ALL',
          initialCategory: 'ALL',
          initialPostCategory: 'INFO',
        ),
      ),
    );
  }

  String _convertCategoryToKorean(String? category) {
    switch (category) {
      case 'DRAWING': return '그림';
      case 'CODING': return '코딩';
      case 'HOMEWORK': return '과제';
      case 'MUSIC': return '음악';
      case 'WRITING': return '글쓰기';
      case 'PHOTO_VIDEO': return '영상';
      case 'FASHION': return '패션';
      default: return '카테고리 없음';
    }
  }

  static const List<Map<String, dynamic>> aiCategories = [
    {'emoji': '🎨', 'label': '그림 / 이미지'},
    {'emoji': '🎵', 'label': '음악 / 작곡'},
    {'emoji': '🎬', 'label': '영상 제작'},
    {'emoji': '📖', 'label': '소설 / 시'},
    {'emoji': '🧠', 'label': '과제 도움'},
    {'emoji': '🗣️', 'label': '언어 학습'},
    {'emoji': '💻', 'label': '개발 학습'},
    {'emoji': '📝', 'label': '시험 대비'},
    {'emoji': '📄', 'label': '문서 요약'},
    {'emoji': '✉️', 'label': '이메일 자동화'},
    {'emoji': '🔍', 'label': '자료 조사'},
    {'emoji': '📊', 'label': '데이터 분석'},
    {'emoji': '🥗', 'label': '식단 추천'},
    {'emoji': '🧘', 'label': '명상'},
    {'emoji': '🩺', 'label': '의료 상담'},
    {'emoji': '🏃‍♂️', 'label': '운동 루틴'},
    {'emoji': '👨‍💻', 'label': '코드 디버깅'},
    {'emoji': '🔌', 'label': 'API 활용'},
    {'emoji': '🧠', 'label': 'AI 예시'},
    {'emoji': '📱', 'label': 'SNS 제작'},
    {'emoji': '📹', 'label': '유튜브 기획'},
    {'emoji': '👕', 'label': '코디 추천'},
    {'emoji': '💬', 'label': '챗봇 친구'},
    {'emoji': '🚀', 'label': '브랜드 기획'},
    {'emoji': '✍️', 'label': '카피라이팅'},
    {'emoji': '💡', 'label': '사업 아이디어'},
    {'emoji': '📈', 'label': '시장 조사'},
    {'emoji': '🧪', 'label': '음성 합성'},
    {'emoji': '🎭', 'label': '페르소나 AI'},
    {'emoji': '🕹️', 'label': '게임 AI'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 2.0, bottom: 2.0),
          child: Row(
            children: [
              Image.asset('assets/logo2.png', width: 100, height: 80),
            ],
          ),
        ),
        leadingWidth: 160,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BoardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥 인기글 TOP 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...popularPosts.map((post) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(postId: post['id']),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(post['title'], style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('카테고리: ${post['category']}'),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📂 카테고리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: aiCategories.map((category) {
                        final isVideo = category['label'] == '영상 제작';
                        return InkWell(
                          onTap: () => _onCategoryTap(category['label']),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isVideo ? 48 : null,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(category['emoji'], style: const TextStyle(fontSize: 24, height: 1.1)),
                              ),
                              const SizedBox(height: 4),
                              Text(category['label'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '쪽지'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '게시판'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
        ],
        onTap: (index) async {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MessageScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardScreen()));
          } else if (index == 3) {
            final loggedIn = await AuthUtil.isLoggedIn();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => loggedIn ? const ProfileScreen() : const GuestProfileScreen()),
            );
          }
        },
      ),
    );
  }
}
