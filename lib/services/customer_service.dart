import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/customer_model.dart';
import 'api_service.dart';

class CustomerService {
  final ApiService _apiService;

  CustomerService(this._apiService);

  final List<CustomerModel> _mockCustomers = [
    CustomerModel(
      id: 'cust_001',
      name: 'Ahmed Al Mansoori',
      companyName: 'Al Maya Trading LLC',
      email: 'ahmed@almaya.ae',
      phone: '+971 50 111 2222',
      whatsappNumber: '+971 50 111 2222',
      branch: 'Dubai',
      emirate: 'Dubai',
      address: 'Business Bay, Tower B, Office 1204',
      totalRevenue: 145000,
      totalDeals: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    CustomerModel(
      id: 'cust_002',
      name: 'John Smith',
      companyName: 'Apex Logistics',
      email: 'jsmith@apexlogistics.com',
      phone: '+971 55 333 4444',
      whatsappNumber: '+971 55 333 4444',
      branch: 'RAK',
      emirate: 'Ras Al Khaimah',
      address: 'Al Hamra Industrial Zone, Plot 44',
      totalRevenue: 280000,
      totalDeals: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    CustomerModel(
      id: 'cust_003',
      name: 'Fatima Al Hammadi',
      companyName: 'Emirates Health Clinic',
      email: 'fatima@ehclinic.ae',
      phone: '+971 52 999 8888',
      whatsappNumber: '+971 52 999 8888',
      branch: 'Dubai',
      emirate: 'Dubai',
      address: 'Jumeirah 1, Villa 88',
      totalRevenue: 95000,
      totalDeals: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  Future<ApiResponse<List<CustomerModel>>> getCustomers({String? search, String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var list = List<CustomerModel>.from(_mockCustomers);
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where((c) => c.name.toLowerCase().contains(q) || (c.companyName?.toLowerCase().contains(q) ?? false)).toList();
      }
      if (branch != null && branch != 'All') {
        list = list.where((c) => c.branch == branch).toList();
      }
      return ApiResponse<List<CustomerModel>>(success: true, data: list);
    }

    return _apiService.get<List<CustomerModel>>(
      ApiEndpoints.customers,
      queryParameters: {
        if (search != null) 'search': search,
        if (branch != null) 'branch': branch,
      },
      fromJson: (json) => (json as List<dynamic>).map((e) => CustomerModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<CustomerModel>> getCustomerById(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final c = _mockCustomers.firstWhere((x) => x.id == id, orElse: () => _mockCustomers.first);
      return ApiResponse<CustomerModel>(success: true, data: c);
    }

    final res = await _apiService.get<CustomerModel>(
      ApiEndpoints.customerDetail(id),
      fromJson: (json) => CustomerModel.fromJson(json as Map<String, dynamic>),
    );
    if (res.success && res.data != null) return res;

    return _apiService.get<CustomerModel>(
      ApiEndpoints.customers,
      queryParameters: {'id': 'eq.$id'},
      fromJson: (json) {
        if (json is List && json.isNotEmpty) {
          return CustomerModel.fromJson(json.first as Map<String, dynamic>);
        }
        return CustomerModel.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<CustomerModel>> createCustomer(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newCustomer = CustomerModel.fromJson({
        'id': 'cust_${DateTime.now().millisecondsSinceEpoch}',
        'name': payload['name'] ?? '',
        'company_name': payload['company_name'],
        'email': payload['email'] ?? '',
        'phone': payload['phone'] ?? '',
        'whatsapp_number': payload['whatsapp_number'] ?? payload['phone'] ?? '',
        'branch': payload['branch'] ?? 'Dubai',
        'emirate': payload['emirate'] ?? 'Dubai',
        'address': payload['address'] ?? '',
        'total_revenue': 0,
        'total_deals': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      _mockCustomers.insert(0, newCustomer);
      return ApiResponse<CustomerModel>(success: true, message: 'Customer created successfully', data: newCustomer);
    }

    return _apiService.post<CustomerModel>(
      ApiEndpoints.customers,
      data: payload,
      fromJson: (json) => CustomerModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
