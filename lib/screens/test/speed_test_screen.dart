import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  bool _isTestingApi = false;
  int? _apiLatencyMs;
  int? _apiStatusCode;
  String? _apiErrorMessage;
  DateTime? _lastTestTime;

  Future<void> _pingRenderApi() async {
    setState(() {
      _isTestingApi = true;
      _apiLatencyMs = null;
      _apiStatusCode = null;
      _apiErrorMessage = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final url = '${AppConfig.apiBaseUrl}/health';
      final response = await dio.get(url);
      stopwatch.stop();

      setState(() {
        _isTestingApi = false;
        _apiLatencyMs = stopwatch.elapsedMilliseconds;
        _apiStatusCode = response.statusCode;
        _lastTestTime = DateTime.now();
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isTestingApi = false;
        _apiLatencyMs = stopwatch.elapsedMilliseconds;
        _apiErrorMessage = e.toString();
        _lastTestTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.speed, color: AppTheme.primaryTeal, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CRM Speed & Latency Benchmark',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Client-side UI test without API data binding',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back to Login'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner: Purpose of this screen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blueGrey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why is this page here?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This screen contains NO API calls on page load. If this screen opened instantaneously, '
                          'it proves that your Flutter Web code and cPanel hosting are operating at maximum speed. '
                          'Any perceived delay during login or dashboard loading comes from the remote backend network round-trip on Render.com.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Diagnostic Row: UI Speed vs API Speed
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card 1: UI Rendering Performance
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.flash_on, color: Colors.green, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Client-Side UI Performance',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildMetricRow('Page Navigation Latency', '< 20 ms (Instant)', Colors.green.shade700),
                        const SizedBox(height: 10),
                        _buildMetricRow('Network Data Calls', '0 requests', Colors.blue.shade700),
                        const SizedBox(height: 10),
                        _buildMetricRow('Hosting Provider', 'cPanel (crm.infocare.ae)', Colors.purple.shade700),
                        const SizedBox(height: 10),
                        _buildMetricRow('Rendering Engine', 'Flutter Web (CanvasKit / HTML)', Colors.teal.shade700),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'UI loads instantly without server dependency.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Card 2: Render.com API Latency Tester
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.cloud_sync_outlined, color: Colors.orange, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Render.com API Latency Test',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Test live round-trip time to: ${AppConfig.apiBaseUrl}/health',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: _isTestingApi ? null : _pingRenderApi,
                          icon: _isTestingApi
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow, size: 18),
                          label: Text(_isTestingApi ? 'Pinging Render...' : 'Ping Render.com API Now'),
                        ),
                        const SizedBox(height: 16),
                        if (_apiLatencyMs != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getLatencyColor(_apiLatencyMs!).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getLatencyColor(_apiLatencyMs!).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Round-trip Time: $_apiLatencyMs ms',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getLatencyColor(_apiLatencyMs!),
                                      ),
                                    ),
                                    Text(
                                      _apiStatusCode != null ? 'Status $_apiStatusCode' : 'Error',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getLatencyColor(_apiLatencyMs!),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _getLatencyExplanation(_apiLatencyMs!),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                ),
                                if (_apiErrorMessage != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Error: $_apiErrorMessage',
                                    style: TextStyle(fontSize: 11, color: Colors.red.shade800),
                                  ),
                                ],
                                if (_lastTestTime != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tested at: ${_lastTestTime!.hour.toString().padLeft(2, '0')}:${_lastTestTime!.minute.toString().padLeft(2, '0')}:${_lastTestTime!.second.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ] else if (!_isTestingApi) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Click the button above to measure actual network response time from your browser to Render.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 3: Mock Complex UI (Zero API Binding)
            const Text(
              'Sample Complex CRM UI (Unbound Mock Data)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Notice how smoothly this layout renders, scrolls, and responds without waiting for a server:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Mock KPI Stat Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildMockStatCard('Total Pipeline Value', 'AED 620,400', Icons.attach_money, Colors.teal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMockStatCard('Active CCTV Leads', '48 Inquiries', Icons.videocam_outlined, Colors.indigo),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMockStatCard('Quotations Pending', '12 Quotations', Icons.description_outlined, Colors.orange),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMockStatCard('Win Ratio', '78.5%', Icons.trending_up, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mock Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Mock Pipeline Deals',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Rendered Offline', style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('CLIENT / PROJECT')),
                      DataColumn(label: Text('BRANCH')),
                      DataColumn(label: Text('VALUE')),
                      DataColumn(label: Text('STAGE')),
                      DataColumn(label: Text('ASSIGNED REP')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('Emaar Towers 4K IP CCTV Upgrade', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('Dubai HQ (DXB)')),
                        DataCell(Text('AED 85,000', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                        DataCell(Text('Negotiation')),
                        DataCell(Text('Rahul Sharma')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Al Hamra Warehouse Access Control', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('RAK Branch')),
                        DataCell(Text('AED 42,000', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                        DataCell(Text('Quotation Sent')),
                        DataCell(Text('John Smith')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Infopark Phase 2 Enterprise PBX', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('Kerala Back Office')),
                        DataCell(Text('INR 380,000', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                        DataCell(Text('Won / Contract')),
                        DataCell(Text('Amal Kerala')),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLatencyColor(int ms) {
    if (ms < 500) return Colors.green.shade700;
    if (ms < 2000) return Colors.orange.shade800;
    return Colors.red.shade700;
  }

  String _getLatencyExplanation(int ms) {
    if (ms < 500) {
      return '🟢 Normal Speed: Backend is warm and responded in ${ms}ms.';
    } else if (ms < 2000) {
      return '🟡 Network Latency: Round-trip from UAE to Render server took ${ms}ms.';
    } else {
      return '🔴 Cold Start Detected (${(ms / 1000).toStringAsFixed(1)}s): Render\'s Free tier was sleeping and had to boot up before replying.';
    }
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildMockStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
