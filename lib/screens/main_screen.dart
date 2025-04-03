import 'package:flutter/material.dart';
import 'package:showtok/screens/profile_screen.dart';
import 'package:showtok/screens/guest_profile_screen.dart';
import 'package:showtok/utils/auth_util.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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

  void _showCategoryPopup(BuildContext context, String label) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label 카테고리',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...['초급', '중급', '고급', '게시판'].map((level) {
                return ListTile(
                  leading: const Icon(Icons.chevron_right),
                  title: Text(level),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 이동 처리
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔥 인기글 박스
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
                    const Text(
                      '🔥 인기글 TOP 3',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      itemCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '게시글 제목',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('작성자 ID'),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // 📂 카테고리 박스
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
                    const Text(
                      '📂 카테고리',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children:
                          aiCategories.map((category) {
                            return InkWell(
                              onTap:
                                  () => _showCategoryPopup(
                                    context,
                                    category['label'],
                                  ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      category['emoji'],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    category['label'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                  ),
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '기능예정'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '프로필',
          ),
        ],
        onTap: (index) async {
          if (index == 3) {
            final loggedIn = await AuthUtil.isLoggedIn();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        loggedIn
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
