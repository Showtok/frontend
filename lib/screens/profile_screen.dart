import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/screens/guest_profile_screen.dart';
import 'package:showtok/screens/main_screen.dart';
import 'package:showtok/utils/auth_util.dart';
import 'package:showtok/constants/api_config.dart';
import 'board_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? nickname;
  String? username;
  String? phone;
  int? credit;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final token = await AuthUtil.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nickname = data['nickname'];
          username = data['username'];
          phone = data['phone'];
          credit = data['credit'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const GuestProfileScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('프로필', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 🔹 사용자 정보 박스
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
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nickname ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('아이디: $username'),
                                Text('전화번호: $phone'),
                                Text('보유 크레딧: ${credit ?? 0}개'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🔹 활동
                      _buildSectionCard([
                        _buildProfileItem(
                          Icons.article_outlined,
                          '내가 작성한 글',
                          () {},
                        ),
                        _buildProfileItem(
                          Icons.comment_outlined,
                          '내가 쓴 댓글',
                          () {},
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // 🔹 설정 (로그아웃 포함)
                      _buildSectionCard([
                        _buildProfileItem(
                          Icons.person_outline,
                          '아이디 변경',
                          () {},
                        ),
                        _buildProfileItem(Icons.lock_outline, '비밀번호 변경', () {}),
                        _buildProfileItem(Icons.edit_note, '닉네임 변경', () {}),
                        _buildProfileItem(Icons.logout, '로그아웃', () async {
                          await AuthUtil.logout();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }),
                        _buildProfileItem(Icons.delete_forever, '회원 탈퇴', () {}),
                      ]),

                      const SizedBox(height: 16),

                      // 🔹 앱 정보
                      _buildSectionCard([
                        _buildProfileItem(
                          Icons.info_outline,
                          '앱 버전 v0.0.5',
                          null,
                        ),
                        _buildProfileItem(Icons.mail_outline, '문의하기', null),
                        _buildProfileItem(
                          Icons.campaign_outlined,
                          '공지사항',
                          null,
                        ),
                      ]),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

      // 🔹 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // 현재 위치는 '프로필'
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '쪽지'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '게시판'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '프로필',
          ),
        ],
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BoardScreen()),
            );
          } else if (index == 3) {
            // 현재 프로필 화면이므로 아무 동작 안 함
          }
        },
      ),
    );
  }

  // 🔧 카드 박스 공통 UI
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
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // 🔧 프로필 항목 UI
  Widget _buildProfileItem(
    IconData icon,
    String text,
    VoidCallback? onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(text, style: TextStyle(color: color ?? Colors.black)),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
