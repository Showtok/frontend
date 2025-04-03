import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const nickname = '기웅';
    const username = 'kiwoong123';
    const phone = '010-1234-5678';
    const credit = 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('프로필', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 🔹 유저 정보 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, size: 40, color: Colors.blueAccent),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('아이디: $username'),
                        Text('전화번호: $phone'),
                        Text('보유 크레딧: ${credit}개'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 활동 영역
              _buildSectionCard([
                _buildProfileItem(Icons.article_outlined, '내가 작성한 글', () {}),
                _buildProfileItem(Icons.comment_outlined, '내가 쓴 댓글', () {}),
              ]),

              const SizedBox(height: 16),

              // 🔹 설정 영역
              _buildSectionCard([
                _buildProfileItem(Icons.person_outline, '아이디 변경', () {}),
                _buildProfileItem(Icons.lock_outline, '비밀번호 변경', () {}),
                _buildProfileItem(Icons.edit_note, '닉네임 변경', () {}),
                _buildProfileItem(Icons.delete_forever, '회원 탈퇴', () {
                  // TODO: 탈퇴 처리
                }),
              ]),

              const SizedBox(height: 16),

              // 🔹 앱 정보 영역 (장식용)
              _buildSectionCard([
                _buildProfileItem(Icons.info_outline, '앱 버전 v0.0.5', null),
                _buildProfileItem(Icons.mail_outline, '문의하기', null),
                _buildProfileItem(Icons.campaign_outlined, '공지사항', null),
              ]),

              const SizedBox(height: 40), // 하단 여백
              // 🔹 로그아웃 버튼123
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 카드 박스 공통 레이아웃
  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  // 🔧 프로필 항목 버튼 (onTap == null 이면 장식용)
  Widget _buildProfileItem(IconData icon, String text, VoidCallback? onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(text, style: TextStyle(color: color ?? Colors.black)),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
