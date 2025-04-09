// 📬 MessageScreen.dart - 받은 쪽지 목록 + 읽음 처리 (완전한 UI 반영)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/constants/api_config.dart';
import 'package:showtok/screens/board_screen.dart';
import 'package:showtok/screens/main_screen.dart';
import 'package:showtok/screens/profile_screen.dart';
import 'package:showtok/screens/guest_profile_screen.dart';
import 'package:showtok/screens/message_create_screen.dart';
import 'package:showtok/utils/auth_util.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<dynamic> receivedMessages = [];
  bool isLoading = true;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final token = await AuthUtil.getToken();
    if (token == null) {
      setState(() {
        isGuest = true;
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        receivedMessages = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      print('쪽지 불러오기 실패: ${response.statusCode}');
    }
  }

  Future<void> _markAsRead(dynamic messageId) async {
    final token = await AuthUtil.getToken();
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/messages/$messageId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void _handleMessageTap(int messageId, bool isRead) async {
    if (!isRead) {
      await _markAsRead(messageId);
      setState(() {
        receivedMessages = receivedMessages.map((m) {
          if (m['id'] == messageId) {
            return {...m, 'read': true};
          }
          return m;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('받은 쪽지함', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final loggedIn = await AuthUtil.isLoggedIn();
              if (!loggedIn && context.mounted) {
                final shouldLogin = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('로그인이 필요합니다'),
                    content: const Text('로그인이 필요한 서비스입니다. 로그인하시겠습니까?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('로그인')),
                    ],
                  ),
                );
                if (shouldLogin == true && context.mounted) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestProfileScreen()));
                }
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessageCreateScreen()),
              ).then((_) => _fetchMessages());
            },
            child: const Text('쪽지 작성', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : receivedMessages.isEmpty || isGuest
          ? const Center(child: Text('받은 쪽지가 없습니다'))
          : ListView.builder(
        itemCount: receivedMessages.length,
        itemBuilder: (context, index) {
          final message = receivedMessages[index];
          final isRead = message['read'] ?? false;
          final sender = message['sender'] ?? '알 수 없음';
          final content = message['content'] ?? '';
          final id = message['id'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: isRead ? Colors.white : const Color(0xFFF9F4FF),
            child: ListTile(
              title: Text(content),
              subtitle: Text('보낸 사람: $sender'),
              trailing: Text('읽음'),
              onTap: () => _handleMessageTap(id, isRead),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '쪽지'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '게시판'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
        ],
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
          } else if (index == 1) {
            // 현재 화면
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BoardScreen()));
          } else if (index == 3) {
            final loggedIn = await AuthUtil.isLoggedIn();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => loggedIn ? const ProfileScreen() : const GuestProfileScreen()),
            );
          }
        },
      ),
    );
  }
}