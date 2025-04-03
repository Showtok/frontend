import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main_screen.dart'; // ✅ 메인화면 임포트

class GuestProfileScreen extends StatelessWidget {
  const GuestProfileScreen({super.key});

  // 🔹 공통 하얀 박스 UI
  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  // 🔹 비활성화된 항목
  Widget _buildDisabledItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(label, style: TextStyle(color: Colors.grey[600])),
      enabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('프로필', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // 🔹 사용자 정보 박스
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    '로그인이 필요합니다 (눌러서 로그인)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 내가 작성한 글/댓글
            _buildSectionCard([
              _buildDisabledItem(Icons.article_outlined, '내가 작성한 글'),
              _buildDisabledItem(Icons.comment_outlined, '내가 쓴 댓글'),
            ]),

            // 🔹 설정
            _buildSectionCard([
              _buildDisabledItem(Icons.person_outline, '아이디 변경'),
              _buildDisabledItem(Icons.lock_outline, '비밀번호 변경'),
              _buildDisabledItem(Icons.edit_note, '닉네임 변경'),
              _buildDisabledItem(Icons.delete_forever, '회원 탈퇴'),
            ]),

            // 🔹 앱 정보
            _buildSectionCard([
              _buildDisabledItem(Icons.info_outline, '앱 버전 v0.0.5'),
              _buildDisabledItem(Icons.mail_outline, '문의하기'),
              _buildDisabledItem(Icons.campaign_outlined, '공지사항'),
            ]),
          ],
        ),
      ),

      // ✅ 하단 네비게이션 바 추가
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // 프로필 탭 선택
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '쪽지'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '기능예정'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
        ],
        onTap: (index) {
          if (index == 0) {
            // ✅ 홈 탭 누르면 메인화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          }
        },
      ),
    );
  }
}
