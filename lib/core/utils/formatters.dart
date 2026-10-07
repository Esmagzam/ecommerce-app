import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'mn_MN');

  static String formatCurrency(num? amount) {
    if (amount == null) return '0₮';
    return '${_currencyFormat.format(amount)}₮';
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
