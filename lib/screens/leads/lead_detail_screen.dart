import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/lead_controller.dart';
import '../../models/lead_model.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/loading_widget.dart';
import 'forms/activity_form.dart';
import 'forms/lead_form.dart';

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late final LeadController _controller;
  late final TextEditingController _aiDraftController;

  static const List<Map<String, String>> _pipelineStages = [
    {'key': 'new', 'label': 'New'},
    {'key': 'contacted', 'label': 'Contacted'},
    {'key': 'site_survey', 'label': 'Site survey'},
    {'key': 'quotation_sent', 'label': 'Quotation sent'},
    {'key': 'negotiation', 'label': 'Negotiation'},
    {'key': 'won', 'label': 'Won / Lost'},
  ];

  @override
  void initState() {
    super.initState();
    _aiDraftController = TextEditingController();
    final leadId = Get.parameters['id'] ?? 'lead_001';
    _controller = Get.isRegistered<LeadController>()
        ? Get.find<LeadController>()
        : Get.put(LeadController());
    _controller.selectLead(leadId);
  }

  @override
  void dispose() {
    _aiDraftController.dispose();
    super.dispose();
  }

  int _getStageIndex(String currentStage) {
    final stage = currentStage.toLowerCase();
    switch (stage) {
      case 'new':
        return 0;
      case 'contacted':
        return 1;
      case 'site_survey':
        return 2;
      case 'quotation_sent':
        return 3;
      case 'negotiation':
        return 4;
      case 'won':
      case 'lost':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.leads),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Lead Inbox'),
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value || _controller.selectedLead.value == null) {
                      return const LoadingWidget(message: 'Loading lead details...');
                    }

                    final lead = _controller.selectedLead.value!;
                    final currentStageIndex = _getStageIndex(lead.stage);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb Navigation
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Get.back(),
                                child: const Text(
                                  'Leads',
                                  style: TextStyle(
                                    color: AppTheme.primaryTeal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const Text(
                                ' / ',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              Text(
                                lead.companyName ?? lead.contactName,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Header Title Row (Title + Badges + Action Buttons)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    Text(
                                      '${lead.companyName ?? lead.contactName} — ${lead.requirement}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        lead.source.replaceAll('_', ' ').capitalizeFirst ?? lead.source,
                                        style: const TextStyle(
                                          color: AppTheme.primaryTeal,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        lead.branch,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.textPrimary,
                                      side: const BorderSide(color: AppTheme.border),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primaryTeal),
                                    label: const Text('Edit lead', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    onPressed: () => Get.dialog(LeadFormDialog(lead: lead)),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.textPrimary,
                                      side: const BorderSide(color: AppTheme.border),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: () => Get.dialog(ActivityFormDialog(leadId: lead.id)),
                                    child: const Text('Log activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryTeal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      elevation: 0,
                                    ),
                                    onPressed: () => Get.toNamed(AppRoutes.quotes),
                                    child: const Text('Open quotation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Stage Progress Bar (Full Width Interactive Stepper)
                          _buildStageStepper(lead, lead.stage, currentStageIndex),
                          const SizedBox(height: 24),

                          // 3-Column Layout Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column 1: Lead Details (Left)
                              Expanded(
                                flex: 3,
                                child: _buildLeadDetailsCard(lead),
                              ),
                              const SizedBox(width: 20),

                              // Column 2: Activity Timeline (Middle)
                              Expanded(
                                flex: 4,
                                child: _buildActivityCard(lead),
                              ),
                              const SizedBox(width: 20),

                              // Column 3: AI Assistant (Right)
                              Expanded(
                                flex: 3,
                                child: _buildAiAssistantCard(lead),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleWonLostSelection(LeadModel lead) {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Stage: Won or Lost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select the outcome for "${lead.companyName ?? lead.contactName}":'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark Won'),
                    onPressed: () {
                      Get.back();
                      _controller.updateLeadStage(lead.id, 'won');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Mark Lost'),
                    onPressed: () {
                      Get.back();
                      _promptLostReason(lead);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _promptLostReason(LeadModel lead) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Lost Reason Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please specify why this deal was marked as Lost:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Price higher than competitor, Project deferred...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              final reason = reasonController.text.trim();
              Get.back();
              _controller.updateLeadStage(lead.id, 'lost', lostReason: reason.isNotEmpty ? reason : 'Marked lost');
            },
            child: const Text('Confirm Lost'),
          ),
        ],
      ),
    );
  }

  Widget _buildStageStepper(LeadModel lead, String currentStage, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(_pipelineStages.length, (index) {
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;
          final stageKey = _pipelineStages[index]['key']!;
          final stageLabel = _pipelineStages[index]['label']!;

          Color bgColor;
          Color textColor;
          if (isCurrent) {
            bgColor = AppTheme.primaryTeal;
            textColor = Colors.white;
          } else if (isCompleted) {
            bgColor = const Color(0xFFCCFBF1);
            textColor = AppTheme.primaryTeal;
          } else {
            bgColor = const Color(0xFFE2E8F0).withValues(alpha: 0.5);
            textColor = const Color(0xFF64748B);
          }

          return Expanded(
            child: Tooltip(
              message: isCurrent ? 'Current stage' : 'Click to move to $stageLabel',
              child: InkWell(
                onTap: () {
                  if (stageKey == currentStage) return;
                  if (stageKey == 'won') {
                    _handleWonLostSelection(lead);
                  } else {
                    _controller.updateLeadStage(lead.id, stageKey);
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCompleted) ...[
                        const Icon(Icons.check, size: 14, color: AppTheme.primaryTeal),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          stageLabel,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLeadDetailsCard(LeadModel lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.contactName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Owner, ${lead.companyName ?? "Independent Client"}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Get.dialog(LeadFormDialog(lead: lead)),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 13, color: AppTheme.primaryTeal),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Phone', lead.phone),
          _buildDetailRow('Email', lead.email),
          _buildLocationDetail(lead),
          _buildDetailRow('Source · campaign', '${lead.source.replaceAll("_", " ").capitalizeFirst} · ${lead.campaign ?? "Direct"}'),
          _buildDetailRow('Captured by', '${lead.capturedBy ?? "System"}, ${AppDateUtils.formatDateTime(lead.createdAt, format: "dd MMM")}'),
          _buildDetailRow('Estimated value', CurrencyUtils.format(lead.estimatedValue), isBoldValue: true),
          _buildDetailRow('Products', lead.productInterest ?? 'IP CCTV, NVR, Mobile Viewing'),
        ],
      ),
    );
  }

  Widget _buildLocationDetail(LeadModel lead) {
    final hasLoc = lead.hasLocation;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Location',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
              ),
              InkWell(
                onTap: () => Get.dialog(LeadFormDialog(lead: lead)),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  child: Text(
                    hasLoc ? 'Edit' : '(Set location)',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (hasLoc)
            Tooltip(
              message: 'Click to open in Google Maps (${lead.latitude != null ? "${lead.latitude}, ${lead.longitude}" : lead.location})',
              child: InkWell(
                onTap: () async {
                  final ok = await lead.openGoogleMaps();
                  if (!ok) {
                    Get.snackbar(
                      'Google Maps',
                      'Opening map at: ${lead.googleMapsUrl}',
                      duration: const Duration(seconds: 4),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(6),
                hoverColor: const Color(0xFFCCFBF1).withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFFEA4335)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          lead.displayLocation,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.open_in_new, size: 13, color: AppTheme.primaryTeal),
                    ],
                  ),
                ),
              ),
            )
          else
            const Row(
              children: [
                Icon(Icons.location_off_outlined, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 5),
                Text(
                  'Location not recorded',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isBoldValue ? AppTheme.textPrimary : const Color(0xFF334155),
              fontSize: 13,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(LeadModel lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              IconButton(
                icon: const Icon(Icons.add, size: 18, color: AppTheme.textSecondary),
                tooltip: 'Log new activity',
                onPressed: () => Get.dialog(ActivityFormDialog(leadId: lead.id)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (_controller.leadActivities.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No activities logged yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.leadActivities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final act = _controller.leadActivities[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${AppDateUtils.formatDateTime(act.createdAt, format: "dd MMM")} · ${act.createdBy}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    act.type.replaceAll('_', ' ').toUpperCase(),
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act.description,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.35, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Prominent Edit and Delete buttons next to each activity
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Edit activity',
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryTeal,
                                side: const BorderSide(color: Color(0xFF99F6E4)),
                                backgroundColor: const Color(0xFFF0FDFA),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(0, 28),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 12),
                              label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              onPressed: () => Get.dialog(ActivityFormDialog(leadId: lead.id, activity: act)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Tooltip(
                            message: 'Delete activity',
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(color: Color(0xFFFECACA)),
                                backgroundColor: const Color(0xFFFEF2F2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(0, 28),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 12),
                              label: const Text('Delete', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Delete Activity',
                                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  middleText: 'Are you sure you want to delete this activity log?',
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  buttonColor: const Color(0xFFEF4444),
                                  onConfirm: () {
                                    Get.back();
                                    _controller.deleteActivity(lead.id, act.id);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAiAssistantCard(LeadModel lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: AppTheme.primaryTeal),
                  SizedBox(width: 8),
                  Text('AI assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 12, color: Colors.amberAccent),
                    SizedBox(width: 3),
                    Text(
                      'Claude',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lead.aiNextStep != null && lead.aiNextStep!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.4),
                  children: [
                    const TextSpan(text: 'Next step: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                    TextSpan(text: lead.aiNextStep!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Draft Email Header & Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Draft email', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
              if (_aiDraftController.text.isNotEmpty)
                InkWell(
                  onTap: () {
                    setState(() {
                      _aiDraftController.clear();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text('Clear draft', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Tone selection chips
          Obx(() {
            final tones = ['Professional', 'Friendly', 'Concise', 'Follow-up'];
            return Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tones.map((tone) {
                final isSelected = _controller.selectedTone.value == tone;
                return InkWell(
                  onTap: () => _controller.selectedTone.value = tone,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFCCFBF1) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      tone,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryTeal : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 8),

          // Draft input area (can be ANY email, not restricted to quotation)
          Builder(builder: (context) {
            if (_aiDraftController.text.isEmpty && lead.aiDraftReply != null && lead.aiDraftReply!.isNotEmpty) {
              _aiDraftController.text = lead.aiDraftReply!;
            }
            return TextFormField(
              controller: _aiDraftController,
              maxLines: 6,
              minLines: 4,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.45, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Type rough notes or draft any email here...\n\nExamples:\n• "Hi Mr. Rex, following up on our meeting..."\n• "Need to confirm delivery date for access control hardware..."\n\nClick "Rewrite" and Claude will polish it into a business email.',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // Action Buttons: Approve & send and Rewrite with Claude
          Obx(() {
            final isRewriting = _controller.isRewriting.value;
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Approve & send', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: isRewriting
                        ? null
                        : () {
                            final emailText = _aiDraftController.text.trim();
                            if (emailText.isEmpty) {
                              Get.snackbar(
                                'Draft Required',
                                'Please enter some text or click Rewrite to generate an email before sending.',
                                backgroundColor: const Color(0xFFEF4444),
                                colorText: Colors.white,
                              );
                              return;
                            }
                            _controller.sendEmailToLead(lead, emailText);
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: const BorderSide(color: AppTheme.primaryTeal, width: 1.2),
                      backgroundColor: const Color(0xFFF0FDFA),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: isRewriting
                        ? null
                        : () async {
                            final currentText = _aiDraftController.text.trim();
                            final promptDraft = currentText.isNotEmpty
                                ? currentText
                                : 'Draft an email to ${lead.contactName} regarding ${lead.requirement.isNotEmpty ? lead.requirement : "our upcoming steps"}.';

                            final rewritten = await _controller.rewriteEmailWithClaude(
                              promptDraft,
                              tone: _controller.selectedTone.value,
                            );
                            if (rewritten != null && rewritten.isNotEmpty) {
                              setState(() {
                                _aiDraftController.text = rewritten;
                              });
                            }
                          },
                    child: isRewriting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Rewriting...',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryTeal),
                              SizedBox(width: 4),
                              Text('Rewrite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 13, color: AppTheme.textMuted),
                  SizedBox(width: 4),
                  Text(
                    'Nothing is sent without your approval',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              Tooltip(
                message: 'Copy draft to clipboard',
                child: InkWell(
                  onTap: () {
                    final text = _aiDraftController.text.trim();
                    if (text.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: text));
                      Get.snackbar('Copied', 'Email draft copied to clipboard', duration: const Duration(seconds: 2));
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: AppTheme.textSecondary),
                        SizedBox(width: 3),
                        Text('Copy', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
