import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/task_model.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  final List<TaskModel> _mockTasks = [
    TaskModel(
      id: 'tsk_001',
      title: 'Call Al Maya Trading regarding CCTV BOQ',
      description: 'Discuss 4K camera options and installation timeline.',
      leadId: 'lead_001',
      relatedToTitle: 'Al Maya Trading (AED 45,000)',
      assignedUserId: 'usr_1001',
      assignedUserName: 'Sarah Connor',
      dueDate: DateTime.now().add(const Duration(hours: 3)),
      priority: 'high',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TaskModel(
      id: 'tsk_002',
      title: 'Send revised quotation to Apex Logistics',
      description: 'Apply approved 5% bundle discount for Cisco switches.',
      leadId: 'lead_002',
      relatedToTitle: 'Apex Logistics (AED 120,000)',
      assignedUserId: 'usr_1002',
      assignedUserName: 'Rahul Verma',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: 'medium',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TaskModel(
      id: 'tsk_003',
      title: 'Follow up on Emirates Health PBX contract',
      description: 'Confirm client signed PO copy.',
      leadId: 'lead_003',
      relatedToTitle: 'Emirates Health Clinic (AED 28,000)',
      assignedUserId: 'usr_1001',
      assignedUserName: 'Sarah Connor',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: 'urgent',
      status: 'overdue',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  Future<ApiResponse<List<TaskModel>>> getTasks({String? status, String? priority, String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var list = List<TaskModel>.from(_mockTasks);
      if (status != null && status != 'All') {
        list = list.where((t) => t.status == status).toList();
      }
      return ApiResponse<List<TaskModel>>(success: true, data: list);
    }

    return _apiService.get<List<TaskModel>>(
      ApiEndpoints.tasks,
      queryParameters: {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (branch != null) 'branch': branch,
      },
      fromJson: (json) => (json as List<dynamic>).map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<TaskModel>> updateTaskStatus(String id, String status) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _mockTasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _mockTasks[index] = _mockTasks[index].copyWith(status: status);
        return ApiResponse<TaskModel>(success: true, data: _mockTasks[index]);
      }
    }

    return _apiService.patch<TaskModel>(
      ApiEndpoints.taskStatus(id),
      data: {'status': status},
      fromJson: (json) => TaskModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<TaskModel>> createTask(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newTask = TaskModel.fromJson({
        'id': 'tsk_${DateTime.now().millisecondsSinceEpoch}',
        ...payload,
        'created_at': DateTime.now().toIso8601String(),
      });
      _mockTasks.insert(0, newTask);
      return ApiResponse<TaskModel>(success: true, message: 'Task created', data: newTask);
    }

    return _apiService.post<TaskModel>(
      ApiEndpoints.tasks,
      data: payload,
      fromJson: (json) => TaskModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
