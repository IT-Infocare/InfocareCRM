import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/pagination_model.dart';
import 'empty_state.dart';
import 'loading_widget.dart';

class DataTableShell extends StatefulWidget {
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
  State<DataTableShell> createState() => _DataTableShellState();
}

class _DataTableShellState extends State<DataTableShell> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

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
          if (widget.isLoading)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: LoadingWidget(),
                ),
              ),
            )
          else if (widget.rows.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: EmptyState(title: widget.emptyMessage),
                ),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      scrollDirection: Axis.vertical,
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                              columns: widget.columns,
                              rows: widget.rows,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (widget.pagination != null && widget.pagination!.totalPages > 1) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Page ${widget.pagination!.page} of ${widget.pagination!.totalPages} (${widget.pagination!.totalItems} total items)',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: widget.pagination!.page > 1 && widget.onPageChanged != null
                            ? () => widget.onPageChanged!(widget.pagination!.page - 1)
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: widget.pagination!.page < widget.pagination!.totalPages && widget.onPageChanged != null
                            ? () => widget.onPageChanged!(widget.pagination!.page + 1)
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
