import 'package:dio/dio.dart';
import 'package:kids_challenge/data/datasources/api_client.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:kids_challenge/core/config/app_config.dart';

class MissionRepository {
  final ApiClient _apiClient;

  MissionRepository(this._apiClient);

  Future<List<MissionModel>> getMissionsByFamily(String familyId, {bool activeOnly = true}) async {
    final response = await _apiClient.get(
      '${AppConfig.missions}/family/$familyId',
      queryParameters: {'activeOnly': activeOnly},
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MissionModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<MissionModel> createMission(Map<String, dynamic> request) async {
    final response = await _apiClient.post(
      AppConfig.missions,
      data: request,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to create mission');
  }

  Future<MissionModel> updateMission(String missionId, Map<String, dynamic> request) async {
    final response = await _apiClient.put(
      '${AppConfig.missions}/$missionId',
      data: request,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to update mission');
  }

  Future<void> deleteMission(String missionId) async {
    await _apiClient.delete('${AppConfig.missions}/$missionId');
  }

  Future<MissionModel> updateMissionVisibility(String missionId, bool isActive) async {
    final response = await _apiClient.post(
      '${AppConfig.missions}/$missionId/visibility',
      data: {'isActive': isActive},
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update mission visibility');
  }

  Future<MissionAssignmentModel> assignMission(Map<String, dynamic> request) async {
    final response = await _apiClient.post(
      '${AppConfig.missions}/assign',
      data: request,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionAssignmentModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to assign mission');
  }

  Future<List<MissionAssignmentModel>> getMyMissions({String? dueDate}) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.missions}/me',
        queryParameters: dueDate != null ? {'dueDate': dueDate} : null,
      );
      
      print('[MissionRepository] Response status: ${response.statusCode}');
      print('[MissionRepository] Response data: ${response.data}');
      
      // 응답이 Map인지 확인
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> missionData = data['data'] as List;
          return missionData.map((json) => MissionAssignmentModel.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('[MissionRepository] DioException: ${e.response?.statusCode}');
      print('[MissionRepository] DioException data: ${e.response?.data}');
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인해주세요.');
      }
      rethrow;
    } catch (e) {
      print('[MissionRepository] Error: $e');
      rethrow;
    }
  }

  Future<List<MissionAssignmentModel>> getMyApprovedMissions({String? dueDate}) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.missions}/me/approved',
        queryParameters: dueDate != null ? {'dueDate': dueDate} : null,
      );
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> missionData = data['data'] as List;
          return missionData.map((json) => MissionAssignmentModel.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인해주세요.');
      }
      rethrow;
    }
  }

  Future<List<MissionAssignmentModel>> getMyApprovedMissionsInRange({required String startDate, required String endDate}) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.missions}/me/approved',
        queryParameters: {'startDate': startDate, 'endDate': endDate},
      );
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> missionData = data['data'] as List;
          return missionData.map((json) => MissionAssignmentModel.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인해주세요.');
      }
      rethrow;
    }
  }

  Future<List<MissionAssignmentModel>> getPendingMissions(String familyId) async {
    final response = await _apiClient.get(
      '${AppConfig.missions}/pending/$familyId',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MissionAssignmentModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MissionAssignmentModel>> getAssignmentsByFamily(String familyId) async {
    final response = await _apiClient.get(
      '${AppConfig.missions}/family/$familyId/assignments',
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MissionAssignmentModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<MissionAssignmentModel>> getMissionsByFamilyAndUser(
      String familyId, String userId) async {
    final response = await _apiClient.get(
      '${AppConfig.missions}/family/$familyId/user/$userId',
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MissionAssignmentModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<MissionAssignmentModel> completeMission(String assignmentId) async {
    final response = await _apiClient.post(
      '${AppConfig.missions}/$assignmentId/complete',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionAssignmentModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to complete mission');
  }

  Future<MissionAssignmentModel> approveMission(String assignmentId) async {
    final response = await _apiClient.post(
      '${AppConfig.missions}/$assignmentId/approve',
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionAssignmentModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to approve mission');
  }

  Future<MissionAssignmentModel> rejectMission(String assignmentId, {String? comment}) async {
    final response = await _apiClient.post(
      '${AppConfig.missions}/$assignmentId/reject',
      data: comment != null ? {'comment': comment} : null,
    );
    
    if (response.data['success'] == true && response.data['data'] != null) {
      return MissionAssignmentModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to reject mission');
  }
}
