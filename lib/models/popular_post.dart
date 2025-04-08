class PopularPost {
  final String title;
  final String author;
  final String category;
  final int likeCount;
  final int commentCount;

  PopularPost({
    required this.title,
    required this.author,
    required this.category,
    required this.likeCount,
    required this.commentCount,
  });

  factory PopularPost.fromJson(Map<String, dynamic> json) {
    return PopularPost(
      title: json['title'],
      author: json['authorNickname'],
      category: json['category'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
    );
  }
}
