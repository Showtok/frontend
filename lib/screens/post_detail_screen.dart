// PostDetailScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showtok/constants/api_config.dart';
import 'package:showtok/utils/auth_util.dart';
import 'package:showtok/screens/login_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? post;
  List<dynamic> comments = [];
  String commentInput = '';
  int? editingCommentId;
  int likeCount = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
    _fetchComments();
    _fetchLikeCount();
  }

  Future<void> _fetchPostDetail() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/posts/${widget.postId}'));
    if (res.statusCode == 200) {
      setState(() {
        post = jsonDecode(utf8.decode(res.bodyBytes));
      });
    }
  }

  Future<void> _fetchComments() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/comments/${widget.postId}'));
    if (res.statusCode == 200) {
      setState(() {
        comments = jsonDecode(utf8.decode(res.bodyBytes));
      });
    }
  }

  Future<void> _fetchLikeCount() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/posts/${widget.postId}/likes'));
    if (res.statusCode == 200) {
      setState(() {
        likeCount = int.parse(res.body);
      });
    }
  }

  Future<void> _toggleLike() async {
    final isLoggedIn = await AuthUtil.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginPopup();
      return;
    }

    final token = await AuthUtil.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/posts/${widget.postId}/like'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('좋아요가 완료되었습니다')));
      _fetchLikeCount();
    }
  }

  void _showLoginPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그인이 필요한 서비스입니다'),
        content: const Text('로그인 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final isLoggedIn = await AuthUtil.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginPopup();
      return;
    }

    final token = await AuthUtil.getToken();
    final body = jsonEncode({
      'postId': widget.postId,
      'content': commentInput,
    });

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/comments'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      _controller.clear();
      commentInput = '';
      _fetchComments();
    }
  }

  Future<void> _deleteComment(int id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed) {
      final token = await AuthUtil.getToken();
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/comments/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _fetchComments();
    }
  }

  Future<void> _editComment(int id) async {
    final token = await AuthUtil.getToken();
    final body = jsonEncode({'content': commentInput});
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/comments/$id'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: body,
    );
    setState(() {
      editingCommentId = null;
      _controller.clear();
    });
    _fetchComments();
  }

  Widget _buildCommentBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < comments.length; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(comments[i]['author'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () {
                        setState(() {
                          _controller.text = comments[i]['content'];
                          editingCommentId = comments[i]['id'];
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteComment(comments[i]['id']),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(comments[i]['content']),
              ),
            ),
            if (i < comments.length - 1)
              const Divider(height: 16),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('게시글 상세', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: post == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 🟦 게시글 박스
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post!['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('작성자: ${post!['authorNickname']}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.thumb_up_alt_outlined, size: 14),
                            const SizedBox(width: 4),
                            Text('$likeCount'),
                            const SizedBox(width: 12),
                            const Icon(Icons.comment_outlined, size: 14),
                            const SizedBox(width: 4),
                            Text('${post!['commentCount']}'),
                            const SizedBox(width: 12),
                            const Icon(Icons.remove_red_eye_outlined, size: 14),
                            const SizedBox(width: 4),
                            Text('${post!['viewCount']}'),
                          ],
                        ),
                        const Divider(height: 20),
                        const SizedBox(height: 18),
                        Text(post!['content']),
                        const SizedBox(height: 40),
                        // 👍 좋아요 버튼
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: InkWell(
                            onTap: _toggleLike,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.thumb_up_alt, color: Colors.blue),
                                SizedBox(width: 6),
                                Text('좋아요', style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✍️ 댓글 입력 박스
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (val) => commentInput = val,
                            decoration: const InputDecoration(
                              hintText: '댓글을 입력하세요',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 14),
                            minLines: 1,
                            maxLines: 3,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (editingCommentId != null) {
                              _editComment(editingCommentId!);
                            } else {
                              _submitComment();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 💬 댓글 목록 박스
                  _buildCommentBox(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
