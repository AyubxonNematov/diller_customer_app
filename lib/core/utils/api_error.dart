import 'package:dio/dio.dart';

/// API dan kelgan xatolikni o'qib, foydalanuvchiga ko'rsatiladigan matn qaytaradi.
///
/// 422 validation xatolarida `errors` ob'ektidagi barcha xabarlarni
/// alohida qatorlarda ko'rsatadi. Boshqa holatlarda `message` maydoni
/// yoki umumiy xabar qaytariladi.
String parseApiError(dynamic error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        return errors.values
            .expand(
              (v) => v is List
                  ? v.map((e) => e.toString())
                  : [v.toString()],
            )
            .join('\n');
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Server bilan aloqa o\'rnatilmadi',
      DioExceptionType.connectionError => 'Internet aloqasi yo\'q',
      _ => 'Xatolik yuz berdi (${error.response?.statusCode ?? 'no response'})',
    };
  }

  return 'Xatolik yuz berdi';
}
