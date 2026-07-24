class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  const PageResponse({
    this.content = const [],
    this.page = 0,
    this.size = 30,
    this.totalElements = 0,
    this.totalPages = 0,
  });

  factory PageResponse.fromMap(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final raw = json['content'];
    final content = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <T>[];

    return PageResponse<T>(
      content: content,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 30,
      totalElements: json['total_elements'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }

  static const int defaultSize = 30;
  static const int maxSize = 100;
}
