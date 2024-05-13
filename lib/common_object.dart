class Post {
  final int post_id;
  final int writer_id;
  final DateTime create_at;
  final DateTime update_at;
  final String title;
  final String category;
  final String study_name;
  final String content;
  final String progress;
  final int view_count;

  Post(
      {required this.post_id,
        required this.writer_id,
        required this.create_at,
        required this.update_at,
        required this.title,
        required this.category,
        required this.study_name,
        required this.content,
        required this.progress,
        required this.view_count,
        });
}