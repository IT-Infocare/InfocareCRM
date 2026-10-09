import 'package:flutter/material.dart';
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

                          // Stage Progress Bar (Full Width Stepper)
                          _buildStageStepper(lead.stage, currentStageIndex),
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

  Widget _buildStageStepper(String currentStage, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(_pipelineStages.length, (index) {
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;
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
          Text(
            lead.contactName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            'Owner, ${lead.companyName ?? "Independent Client"}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Phone', lead.phone),
          _buildDetailRow('Email', lead.email),
          _buildDetailRow('Location', lead.location ?? 'Dubai, UAE'),
          _buildDetailRow('Source · campaign', '${lead.source.replaceAll("_", " ").capitalizeFirst} · ${lead.campaign ?? "Direct"}'),
          _buildDetailRow('Captured by', '${lead.capturedBy ?? "System"}, ${AppDateUtils.formatDateTime(lead.createdAt, format: "dd MMM")}'),
          _buildDetailRow('Estimated value', CurrencyUtils.format(lead.estimatedValue), isBoldValue: true),
          _buildDetailRow('Products', lead.productInterest ?? 'IP CCTV, NVR, Mobile Viewing'),
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
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final act = _controller.leadActivities[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppDateUtils.formatDateTime(act.createdAt, format: "dd MMM")} · ${act.createdBy}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            act.description,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.35, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              const Text('AI assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Claude',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Next Step Box
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4),
              children: [
                const TextSpan(text: 'Next step: ', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: lead.aiNextStep ?? 'Quote sent 6 days ago, no reply. Call client today and offer a short demo of mobile viewing.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Draft Follow-up Email Box (Editable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Draft follow-up email', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              const Text('(Editable)', style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Builder(builder: (context) {
            final defaultDraft = lead.aiDraftReply ??
                'Dear ${lead.contactName.split(" ").first}, following up on our quotation for the CCTV system at your building. We can arrange a quick demo of viewing all cameras from your phone this week. Would Thursday suit you?';
            if (_aiDraftController.text.isEmpty) {
              _aiDraftController.text = defaultDraft;
            }
            return TextFormField(
              controller: _aiDraftController,
              maxLines: 5,
              minLines: 3,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
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
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final emailText = _aiDraftController.text.trim();
                    _controller.sendEmailToLead(lead, emailText);
                  },
                  child: const Text('Approve & send', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () async {
                  await _controller.rewriteAiDraftReply();
                  if (_controller.selectedLead.value?.aiDraftReply != null) {
                    _aiDraftController.text = _controller.selectedLead.value!.aiDraftReply!;
                  }
                },
                child: const Text('Rewrite', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Nothing is sent without a person approving it.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
