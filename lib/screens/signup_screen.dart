import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/screens/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final nicknameController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '회원가입',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 80),

              // 아이디
              _buildInputField(controller: usernameController, hint: '아이디'),
              const SizedBox(height: 12),

              // 비밀번호
              _buildInputField(
                controller: passwordController,
                hint: '비밀번호',
                obscure: true,
              ),
              const SizedBox(height: 12),

              // 닉네임
              _buildInputField(controller: nicknameController, hint: '닉네임'),
              const SizedBox(height: 12),

              // 전화번호
              _buildInputField(controller: phoneController, hint: '전화번호'),
              const SizedBox(height: 40),

              // 회원가입 버튼
              SizedBox(
                width: 280,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();
                    final nickname = nicknameController.text.trim();
                    final phone = phoneController.text.trim();

                    if ([username, password, nickname, phone].any((e) => e.isEmpty)) {
                      _showDialog(context, '모든 항목을 입력해주세요.');
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse('http://10.0.2.2:8080/api/auth/signup'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'username': username,
                          'password': password,
                          'nickname': nickname,
                          'phone': phone,
                        }),
                      );

                      if (response.statusCode == 200) {
                        if (!context.mounted) return;
                        _showDialog(context, '회원가입이 완료되었습니다!', onConfirm: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        });
                      } else {
                        _showDialog(context, '회원가입에 실패했습니다.');
                      }
                    } catch (e) {
                      _showDialog(context, '서버 오류가 발생했습니다.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📦 공통 인풋 필드 위젯
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // 📦 다이얼로그
  void _showDialog(BuildContext context, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: const Text('확인'),
          )
        ],
      ),
    );
  }
}
