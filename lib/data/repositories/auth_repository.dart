import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService apiService;
  final SecureStorageService secureStorageService;

  AuthRepository({
    required this.apiService,
    required this.secureStorageService,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        '/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await secureStorageService.saveToken(token);
        }
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
      return await getMe();
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await apiService.post(
        '/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await secureStorageService.saveToken(token);
        }
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
      return await getMe();
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await apiService.get('/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
      throw const ServerFailure(message: 'Хэрэглэгчийн мэдээлэл олдсонгүй.');
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on UnauthorizedException {
      throw const AuthFailure();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await apiService.post('/logout');
    } catch (_) {
      // Сүлжээний хүсэлт амжилтгүй болсон ч токеныг локал сангаас заавал устгана
    } finally {
      await secureStorageService.deleteToken();
    }
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await apiService.put(
        '/shop/profile',
        data: {
          'name': name.trim(),
          'email': email.trim(),
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return await getMe();
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await apiService.put(
        '/shop/profile/password',
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<bool> hasSavedToken() async {
    return await secureStorageService.hasToken();
  }
}
