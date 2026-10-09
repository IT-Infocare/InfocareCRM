import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/pipeline_controller.dart';
import '../../models/deal_model.dart';
import '../../utils/currency_utils.dart';
import '../../utils/lead_stage_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/source_badge.dart';

class PipelineScreen extends StatelessWidget {
  const PipelineScreen({super.key});

  void _handleStageMove(BuildContext context, DealModel deal, String newStage) async {
    final controller = Get.find<PipelineController>();
    if (newStage == 'lost') {
      final reasonController = TextEditingController();
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Lost Reason Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please specify the reason why this deal was marked as Lost:'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(hintText: 'e.g. Price higher than competitor, Project cancelled...'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Mark Lost'),
            ),
          ],
        ),
      );

      if (confirm == true && reasonController.text.trim().isNotEmpty) {
        controller.moveDealStage(deal.id, 'lost', lostReason: reasonController.text.trim());
      }
    } else if (newStage == 'won') {
      final confirm = await Get.dialog<bool>(
        ConfirmationDialog(
          title: 'Confirm Won Deal',
          message: 'Are you sure you want to mark ${deal.customerName} as WON? This will trigger quotation finalization.',
          confirmLabel: 'Mark Won',
          confirmColor: AppTheme.success,
        ),
      );
      if (confirm == true) {
        controller.moveDealStage(deal.id, 'won');
      }
    } else {
      controller.moveDealStage(deal.id, newStage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PipelineController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.pipeline),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Sales Pipeline Kanban'),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const LoadingWidget(message: 'Loading deal pipeline...');
                    }

                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.stages.map((stageKey) {
                          final stageDeals = controller.getDealsForStage(stageKey);
                          final stageTotal = controller.getStageTotalValue(stageKey);
                          final stageColor = LeadStageUtils.getColor(stageKey);

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Column(
                                children: [
                                  // Column Header
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      border: Border(bottom: BorderSide(color: stageColor, width: 3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              LeadStageUtils.getLabel(stageKey),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: stageColor,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              CurrencyUtils.formatCompact(stageTotal),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: stageColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${stageDeals.length}',
                                            style: TextStyle(color: stageColor, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Drag & Drop / Cards List
                                  Expanded(
                                    child: DragTarget<DealModel>(
                                      onWillAcceptWithDetails: (details) => details.data.stage != stageKey,
                                      onAcceptWithDetails: (details) {
                                        _handleStageMove(context, details.data, stageKey);
                                      },
                                      builder: (context, candidateData, rejectedData) {
                                        return ListView.builder(
                                          padding: const EdgeInsets.all(12),
                                          itemCount: stageDeals.length,
                                          itemBuilder: (context, index) {
                                            final deal = stageDeals[index];

                                            return Draggable<DealModel>(
                                              data: deal,
                                              feedback: Material(
                                                elevation: 8,
                                                borderRadius: BorderRadius.circular(12),
                                                child: SizedBox(
                                                  width: 260,
                                                  child: _buildDealCard(deal, context),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.3,
                                                child: _buildDealCard(deal, context),
                                              ),
                                              child: _buildDealCard(deal, context),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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

  Widget _buildDealCard(DealModel deal, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: deal.isStalled ? AppTheme.danger : AppTheme.border,
          width: deal.isStalled ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  deal.customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SourceBadge(source: deal.source),
            ],
          ),
          if (deal.companyName != null && deal.companyName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              deal.companyName!,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            deal.requirement,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  CurrencyUtils.format(deal.estimatedValue),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        deal.ownerName.trim().isNotEmpty ? deal.ownerName.trim().split(' ')[0] : 'Unassigned',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${deal.daysInStage} days in stage',
                style: TextStyle(
                  fontSize: 11,
                  color: deal.isStalled ? AppTheme.danger : AppTheme.textMuted,
                  fontWeight: deal.isStalled ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (deal.isStalled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('STALLED', style: TextStyle(fontSize: 9, color: AppTheme.danger, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
