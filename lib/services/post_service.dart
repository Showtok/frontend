import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:showtok/constants/api_config.dart';
import 'package:showtok/models/popular_post.dart';

class PostService {
  static Future<List<PopularPost>> fetchPopularPosts() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/popular'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => PopularPost.fromJson(e)).toList();
    } else {
      throw Exception('인기글을 불러오지 못했습니다');
    }
  }
}
