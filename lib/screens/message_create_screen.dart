// 📩 MessageCreateScreen.dart - 수정된 기능 포함
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/constants/api_config.dart';
import 'package:showtok/utils/auth_util.dart';

class MessageCreateScreen extends StatefulWidget {
  const MessageCreateScreen({super.key});

  @override
  State<MessageCreateScreen> createState() => _MessageCreateScreenState();
}

class _MessageCreateScreenState extends State<MessageCreateScreen> {
  final _receiverController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final receiver = _receiverController.text.trim();
    final content = _contentController.text.trim();

    if (receiver.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    final token = await AuthUtil.getToken();

    setState(() => _isSending = true);

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'receiverUsername': receiver,
        'content': content,
      }),
    );

    setState(() => _isSending = false);

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쪽지 전송 완료! 크레딧 2개 차감됨')),
      );
      Navigator.pop(context);
    } else {
      String errorMsg = '쪽지 전송에 실패했습니다';
      if (response.statusCode == 400 || response.statusCode == 500) {
        try {
          final body = jsonDecode(response.body);
          errorMsg = body['message'] ?? errorMsg;
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('쪽지 작성', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('받는 사람 ID', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _receiverController,
              decoration: const InputDecoration(
                hintText: '받는 사람의 아이디를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('쪽지 내용', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '쪽지 내용을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('쪽지 보내기', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
