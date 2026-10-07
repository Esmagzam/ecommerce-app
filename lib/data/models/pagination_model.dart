class PaginationModel<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginationModel({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];
    final items = <T>[];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(fromJsonT(item));
        }
      }
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    final current = meta?['current_page'] as int? ?? 1;
    final last = meta?['last_page'] as int? ?? 1;
    final totalCount = meta?['total'] as int? ?? items.length;
    final perPageCount = meta?['per_page'] as int? ?? items.length;

    return PaginationModel<T>(
      data: items,
      currentPage: current,
      lastPage: last,
      total: totalCount,
      perPage: perPageCount,
    );
  }
}
