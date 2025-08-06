import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/auth_models.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  Future<User> updateProfile({
    required String username,
    required String phoneNumber,
  }) async {
    final response = await _apiClient.dio.put(
      '/users/me',
      data: {
        'username': username,
        'phone_number': phoneNumber,
      },
    );
    
    return User.fromJson(response.data);
  }
}