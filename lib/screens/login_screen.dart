// 📱 LoginScreen.dart - 구글 로그인 연동 포함 (수정 완료)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:showtok/utils/auth_util.dart';
import 'package:showtok/screens/main_screen.dart';
import 'package:showtok/screens/signup_screen.dart';
import 'package:showtok/constants/api_config.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController pwController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logoplus.png', width: 200, height: 200),
              const SizedBox(height: 20),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: idController,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: '아이디',
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: pwController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 280,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final id = idController.text.trim();
                    final pw = pwController.text.trim();

                    if (id.isEmpty || pw.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          content: Text('아이디와 비밀번호를 모두 입력하세요.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'username': id, 'password': pw}),
                      );

                      if (response.statusCode == 200) {
                        final token = response.body;
                        await AuthUtil.saveToken(token);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(
                            content: Text('로그인에 실패했습니다.'),
                          ),
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          content: Text('서버에 연결할 수 없습니다.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 280,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('회원가입', style: TextStyle(color: Colors.black, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 280,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final googleSignIn = GoogleSignIn(
                        clientId: '253537541471-9nic76ab5iemn24fok7o9kqddpr67mc4.apps.googleusercontent.com',
                      );
                      final account = await googleSignIn.signIn();
                      if (account == null) return;
                      final email = account.email;
                      final name = account.displayName ?? 'GoogleUser';

                      final response = await http.post(
                        Uri.parse('${ApiConfig.baseUrl}/api/auth/oauth/google'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'email': email, 'name': name}), // 👈 이름도 함께 전송
                      );


                      if (response.statusCode == 200) {
                        final token = response.body;
                        await AuthUtil.saveToken(token);
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      } else {
                        print("❌ 백엔드 오류 응답: \${response.body}");
                        showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(content: Text('구글 로그인에 실패했습니다.')),
                        );
                      }
                    } catch (e) {
                      print("❌ 예외 발생: \$e");
                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text('오류'),
                          content: Text('구글 로그인 중 오류가 발생했습니다.'),
                        ),
                      );
                    }
                  },
                  icon: Image.asset('assets/google_logo.png', width: 20, height: 20),
                  label: const Text('구글로 로그인하기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}