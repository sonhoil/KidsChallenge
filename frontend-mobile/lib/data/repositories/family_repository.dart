import 'package:dio/dio.dart';
import 'package:kids_challenge/data/datasources/api_client.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/core/config/app_config.dart';

class FamilyRepository {
  final ApiClient _apiClient;

  FamilyRepository(this._apiClient);

  Future<List<FamilyModel>> getMyFamilies() async {
    try {
      print('[FamilyRepository] Getting my families...');
      final response = await _apiClient.get(AppConfig.families);
      
      print('[FamilyRepository] Response status: ${response.statusCode}');
      print('[FamilyRepository] Response data: ${response.data}');
      
      // 응답이 Map인지 확인
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> familyData = data['data'] as List;
          print('[FamilyRepository] Found ${familyData.length} families');
          return familyData.map((json) => FamilyModel.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('[FamilyRepository] DioException: ${e.response?.statusCode}');
      print('[FamilyRepository] DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인해주세요.');
      }
      rethrow;
    } catch (e) {
      print('[FamilyRepository] Error: $e');
      rethrow;
    }
  }

  Future<FamilyModel> createFamily(Map<String, dynamic> request) async {
    try {
      print('[FamilyRepository] Creating family...');
      print('[FamilyRepository] Request data: $request');
      final response = await _apiClient.post(
        AppConfig.families,
        data: request,
      );
      
      print('[FamilyRepository] Create response status: ${response.statusCode}');
      print('[FamilyRepository] Create response data: ${response.data}');
      
      // 응답이 Map인지 확인
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          print('[FamilyRepository] Successfully created family');
          return FamilyModel.fromJson(data['data']);
        }
        // 에러 메시지가 있으면 사용
        final errorMessage = data['message'] ?? 'Failed to create family';
        throw Exception(errorMessage);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      print('[FamilyRepository] Create DioException: ${e.response?.statusCode}');
      print('[FamilyRepository] Create DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인해주세요.');
      }
      if (e.response?.data is Map) {
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Failed to create family';
        throw Exception(errorMessage);
      }
      rethrow;
    } catch (e) {
      print('[FamilyRepository] Create Error: $e');
      rethrow;
    }
  }

  Future<List<FamilyMemberModel>> getFamilyMembers(String familyId) async {
    final response = await _apiClient.get(
      '${AppConfig.familyMembers}/$familyId/members',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => FamilyMemberModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<FamilyMemberModel> addFamilyMember(String familyId, Map<String, dynamic> request) async {
    final response = await _apiClient.post(
      '${AppConfig.familyMembers}/$familyId/members',
      data: request,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return FamilyMemberModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to add family member');
  }

  Future<FamilyModel> updateFamilyName(String familyId, String name) async {
    final response = await _apiClient.put(
      '${AppConfig.families}/$familyId',
      data: {'name': name},
    );
    if (response.data['success'] == true && response.data['data'] != null) {
      return FamilyModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update family');
  }

  Future<void> deleteFamilyMember(String familyId, String memberId) async {
    final response = await _apiClient.delete(
      '${AppConfig.familyMembers}/$familyId/members/$memberId',
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete family member');
    }
  }

  Future<FamilyModel> joinFamily(String inviteCode, {String? nickname, String? memberId}) async {
    try {
      print('[FamilyRepository] Joining family with invite code: $inviteCode');
      final response = await _apiClient.post(
        '${AppConfig.families}/join',
        data: {
          'inviteCode': inviteCode,
          if (nickname != null) 'nickname': nickname,
          if (memberId != null) 'memberId': memberId,
        },
      );
      
      print('[FamilyRepository] Join response status: ${response.statusCode}');
      print('[FamilyRepository] Join response data: ${response.data}');
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          print('[FamilyRepository] Successfully joined family');
          return FamilyModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to join family');
    } on DioException catch (e) {
      print('[FamilyRepository] Join DioException: ${e.response?.statusCode}');
      print('[FamilyRepository] Join DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw Exception('유효하지 않은 초대코드입니다.');
      }
      rethrow;
    } catch (e) {
      print('[FamilyRepository] Join Error: $e');
      rethrow;
    }
  }
}
