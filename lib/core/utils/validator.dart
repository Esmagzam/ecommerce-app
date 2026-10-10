class Validator {
  Validator._();

  static String? required(
    String? value, [
    String message = 'Энэ талбарыг бөглөнө үү.',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'И-мэйл хаягаа оруулна уу.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Зөв и-мэйл хаяг оруулна уу.';
    }
    return null;
  }

  static String? password(String? value, [int minLength = 6]) {
    if (value == null || value.isEmpty) {
      return 'Нууц үгээ оруулна уу.';
    }
    if (value.length < minLength) {
      return 'Нууц үг хамгийн багадаа $minLength тэмдэгттэй байх ёстой.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Нууц үгээ давтан оруулна уу.';
    }
    if (value != originalPassword) {
      return 'Нууц үг хоорондоо таарахгүй байна.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Утасны дугаараа оруулна уу.';
    }
    final cleanPhone = value.replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^\d{8}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return '8 оронтой зөв утасны дугаар оруулна уу.';
    }
    return null;
  }
}
