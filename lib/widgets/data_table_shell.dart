import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/pagination_model.dart';
import 'empty_state.dart';
import 'loading_widget.dart';

class DataTableShell extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isLoading;
  final PaginationModel? pagination;
  final ValueChanged<int>? onPageChanged;
  final String emptyMessage;

  const DataTableShell({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.pagination,
    this.onPageChanged,
    this.emptyMessage = 'No records found',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: LoadingWidget(),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: EmptyState(title: emptyMessage),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300),
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 20,
                  headingRowHeight: 44,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 64,
                  headingRowColor: WidgetStateProperty.all(AppTheme.background),
                  headingTextStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  dataTextStyle: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  columns: columns,
                  rows: rows,
                ),
              ),
            ),
          if (pagination != null && pagination!.totalPages > 1) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${pagination!.page} of ${pagination!.totalPages} (${pagination!.totalItems} total items)',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: pagination!.page > 1 && onPageChanged != null
                            ? () => onPageChanged!(pagination!.page - 1)
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: pagination!.page < pagination!.totalPages && onPageChanged != null
                            ? () => onPageChanged!(pagination!.page + 1)
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
