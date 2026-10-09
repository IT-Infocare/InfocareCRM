import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/quotation_item_model.dart';
import '../models/quotation_model.dart';
import 'api_service.dart';

class QuotationService {
  final ApiService _apiService;

  QuotationService(this._apiService);

  final List<QuotationModel> _mockQuotations = [
    QuotationModel(
      id: 'qt_101',
      quotationNumber: 'QT-2026-001',
      version: 1,
      status: 'pending_approval',
      validUntil: DateTime.now().add(const Duration(days: 14)),
      customerId: 'cust_001',
      customerName: 'Al Maya Trading LLC',
      leadId: 'lead_001',
      dealId: 'dl_101',
      preparedBy: 'Sarah Connor',
      terms: '50% advance, 50% upon installation completion. 1 year warranty included.',
      subtotal: 42857.14,
      vatAmount: 2142.86,
      totalAmount: 45000.00,
      pdfUrl: 'https://example.com/quotations/QT-2026-001-v1.pdf',
      isAiDraft: true,
      items: [
        QuotationItemModel(
          id: 'qti_01',
          productId: 'prod_cctv_4k',
          productName: 'Hikvision 4K IP Dome Camera 4MP',
          description: 'Outdoor weatherproof vandal-proof dome camera IR 30m',
          quantity: 40,
          unitPrice: 450,
          discount: 5,
          lineTotal: 17100,
          sortOrder: 1,
        ),
        QuotationItemModel(
          id: 'qti_02',
          productId: 'prod_nvr_64ch',
          productName: 'Hikvision 64-Channel NVR recorder 4K',
          description: 'Supports up to 8 SATA HDDs, Dual Gigabit LAN',
          quantity: 1,
          unitPrice: 8500,
          discount: 0,
          lineTotal: 8500,
          sortOrder: 2,
        ),
        QuotationItemModel(
          id: 'qti_03',
          productId: 'prod_cat6a_box',
          productName: 'Cat6A Cable Box 305m High Speed',
          description: 'Pure copper LSZH ethernet cable',
          quantity: 12,
          unitPrice: 650,
          discount: 0,
          lineTotal: 7800,
          sortOrder: 3,
        ),
        QuotationItemModel(
          id: 'qti_04',
          productId: 'prod_installation_labour',
          productName: 'Professional Installation & Configuration',
          description: 'Cable pulling, conduit mounting, NVR config & mobile access setup',
          quantity: 1,
          unitPrice: 9457.14,
          discount: 0,
          lineTotal: 9457.14,
          sortOrder: 4,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    QuotationModel(
      id: 'qt_102',
      quotationNumber: 'QT-2026-002',
      version: 2,
      status: 'approved',
      validUntil: DateTime.now().add(const Duration(days: 30)),
      customerId: 'cust_002',
      customerName: 'Apex Logistics',
      leadId: 'lead_002',
      dealId: 'dl_102',
      preparedBy: 'Rahul Verma',
      terms: '30 days net payment terms for enterprise client.',
      subtotal: 114285.71,
      vatAmount: 5714.29,
      totalAmount: 120000.00,
      pdfUrl: 'https://example.com/quotations/QT-2026-002-v2.pdf',
      isAiDraft: false,
      items: [
        QuotationItemModel(
          id: 'qti_10',
          productId: 'prod_wifi_ap',
          productName: 'Aruba Wi-Fi 6 Enterprise Access Point',
          description: 'High density Wi-Fi 6 indoor AP with PoE support',
          quantity: 25,
          unitPrice: 2800,
          discount: 10,
          lineTotal: 63000,
          sortOrder: 1,
        ),
        QuotationItemModel(
          id: 'qti_11',
          productId: 'prod_poe_switch',
          productName: 'Cisco 48-Port Gigabit Managed PoE+ Switch',
          description: 'Full Layer 3 managed PoE switch with 740W power budget',
          quantity: 3,
          unitPrice: 15500,
          discount: 5,
          lineTotal: 44175,
          sortOrder: 2,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<ApiResponse<List<QuotationModel>>> getQuotations({String? search, String? status, String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var list = List<QuotationModel>.from(_mockQuotations);
      if (status != null && status != 'All') {
        list = list.where((q) => q.status == status).toList();
      }
      return ApiResponse<List<QuotationModel>>(success: true, data: list);
    }

    return _apiService.get<List<QuotationModel>>(
      ApiEndpoints.quotations,
      queryParameters: {
        if (search != null) 'search': search,
        if (status != null) 'status': status,
        if (branch != null) 'branch': branch,
      },
      fromJson: (json) => (json as List<dynamic>).map((e) => QuotationModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<QuotationModel>> getQuotationById(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final q = _mockQuotations.firstWhere((x) => x.id == id, orElse: () => _mockQuotations.first);
      return ApiResponse<QuotationModel>(success: true, data: q);
    }

    final res = await _apiService.get<QuotationModel>(
      ApiEndpoints.quotationDetail(id),
      fromJson: (json) => QuotationModel.fromJson(json as Map<String, dynamic>),
    );
    if (res.success && res.data != null) return res;

    return _apiService.get<QuotationModel>(
      ApiEndpoints.quotations,
      queryParameters: {'id': 'eq.$id'},
      fromJson: (json) {
        if (json is List && json.isNotEmpty) {
          return QuotationModel.fromJson(json.first as Map<String, dynamic>);
        }
        return QuotationModel.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<QuotationModel>> submitApproval(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockQuotations.indexWhere((q) => q.id == id);
      if (index != -1) {
        _mockQuotations[index] = _mockQuotations[index].copyWith(status: 'pending_approval');
        return ApiResponse<QuotationModel>(success: true, message: 'Submitted for management approval', data: _mockQuotations[index]);
      }
    }

    return _apiService.post<QuotationModel>(
      ApiEndpoints.quotationSubmitApproval(id),
      fromJson: (json) => QuotationModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<QuotationModel>> approveQuotation(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockQuotations.indexWhere((q) => q.id == id);
      if (index != -1) {
        _mockQuotations[index] = _mockQuotations[index].copyWith(status: 'approved');
        return ApiResponse<QuotationModel>(success: true, message: 'Quotation approved', data: _mockQuotations[index]);
      }
    }

    return _apiService.post<QuotationModel>(
      ApiEndpoints.quotationApprove(id),
      fromJson: (json) => QuotationModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<QuotationModel>> regenerateAiDraft(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final index = _mockQuotations.indexWhere((q) => q.id == id);
      if (index != -1) {
        _mockQuotations[index] = _mockQuotations[index].copyWith(isAiDraft: true);
        return ApiResponse<QuotationModel>(success: true, message: 'AI draft regenerated', data: _mockQuotations[index]);
      }
    }

    return _apiService.post<QuotationModel>(
      ApiEndpoints.quotationRegenerateAiDraft(id),
      fromJson: (json) => QuotationModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<QuotationModel>> createQuotation(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final numStr = 'QT-2026-${(100 + _mockQuotations.length + 1).toString().padLeft(3, '0')}';
      final newQ = QuotationModel.fromJson({
        'id': 'qt_${DateTime.now().millisecondsSinceEpoch}',
        'quotation_number': numStr,
        'version': 1,
        'status': 'draft',
        'valid_until': payload['valid_until'] ?? DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'customer_id': payload['customer_id'] ?? 'cust_001',
        'customer_name': payload['customer_name'] ?? 'Al Maya Trading LLC',
        'prepared_by': payload['prepared_by'] ?? 'Logged User',
        'terms': payload['terms'] ?? 'Standard Payment Terms',
        'subtotal': 0.0,
        'vat_amount': 0.0,
        'total_amount': 0.0,
        'is_ai_draft': false,
        'items': [],
        'created_at': DateTime.now().toIso8601String(),
      });
      _mockQuotations.insert(0, newQ);
      return ApiResponse<QuotationModel>(success: true, message: 'Quotation created', data: newQ);
    }

    return _apiService.post<QuotationModel>(
      ApiEndpoints.quotations,
      data: payload,
      fromJson: (json) => QuotationModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
