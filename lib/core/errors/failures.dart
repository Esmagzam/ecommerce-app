class Failure {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  const Failure({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  String? getFirstErrorFor(String field) {
    if (fieldErrors == null) return null;
    final list = fieldErrors![field];
    if (list != null && list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Интернэт холболт байхгүй байна. Дахин оролдоно уу.'])
      : super(message: message);
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.fieldErrors,
  });
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Нэвтрэх шаардлагатай байна.'])
      : super(message: message, statusCode: 401);
}
