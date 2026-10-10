class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  const ServerException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Интернэт холболтоо шалгана уу.']);

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([
    this.message = 'Нэвтрэх хугацаа дууссан байна. Дахин нэвтэрнэ үү.',
  ]);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
