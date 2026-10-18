import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/scan_record.dart';
import '../../core/state/history_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// History Screen: Displays list of persisted analysed scans (Owned by Member C)
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, ScanRecord record) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.s8),
            Text(
              'Delete ${record.id}?',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete this scan and all associated image and sensor data from private device storage. This cannot be undone.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondaryText,
            fontSize: 14.0,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.label.copyWith(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(historyProvider.notifier).deleteRecord(record.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${record.id} permanently deleted.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showRenameDialog(BuildContext context, ScanRecord record) {
    final controller = TextEditingController(text: record.label ?? '');

    showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        title: Text(
          'Label ${record.id}',
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16.0, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Do not enter real names or personal details.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Scan Label (Optional)',
                hintText: 'e.g. Forehead Scan #1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(null),
            child: Text(
              'Cancel',
              style: AppTextStyles.label.copyWith(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((newLabel) {
      if (newLabel != null && mounted) {
        ref.read(historyProvider.notifier).updateLabel(record.id, newLabel);
      }
    });
  }

  String _formatTimestamp(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final mon = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $mon $year • $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredHistoryRecordsProvider);
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'History',
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.secondaryText),
            tooltip: 'Reload records',
            onPressed: () => ref.read(historyProvider.notifier).reload(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.s8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(historySearchProvider.notifier).setQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by ID, label or condition',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.secondaryText,
                      size: 20.0,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18.0),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(historySearchProvider.notifier).clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s12,
                    ),
                  ),
                ),
              ),
            ),

            // History Records List / Empty / Loading
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.screenPadding),
                    child: Text(
                      'Loading scans...',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Text(
                      'Failed to load history: $err',
                      style: AppTextStyles.body.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
                data: (allRecords) {
                  if (allRecords.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                size: 40.0,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            Text(
                              'No saved scans yet',
                              style: AppTextStyles.title.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              'Only analysed captures are saved to History.\nData stays strictly in private device storage.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (filteredRecords.isEmpty) {
                    return Center(
                      child: Text(
                        'No scans match "${_searchController.text}"',
                        style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.s8,
                    ),
                    itemCount: filteredRecords.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return _buildRecordCard(context, record);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, ScanRecord record) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(historyProvider.notifier).openRecord(record);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Thumbnail
                  Container(
                    width: 58.0,
                    height: 58.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: record.capture.imageBytes.isNotEmpty
                        ? Image.memory(
                            record.capture.imageBytes,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/avatas/user_avatar_type_II.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.face_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/avatas/user_avatar_type_II.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.face_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  // Content details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              record.id,
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Text(
                                record.prediction.label,
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (record.label != null && record.label!.isNotEmpty) ...[
                          const SizedBox(height: 2.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.label_outline_rounded,
                                size: 12.0,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  record.label!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.secondaryText,
                                    fontSize: 11.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4.0),
                        Text(
                          _formatTimestamp(record.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryText,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions: Rename and Delete
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18.0,
                          color: AppColors.secondaryText,
                        ),
                        tooltip: 'Edit label',
                        onPressed: () => _showRenameDialog(context, record),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18.0,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete scan',
                        onPressed: () => _confirmDelete(context, record),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              // Tags Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                    ),
                    child: Text(
                      'Placeholder model',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                    ),
                    child: Text(
                      record.modelVariant == 'quantized_int8' ? 'INT8' : 'FP32',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  if (record.inferenceMs != null) ...[
                    const SizedBox(width: AppSpacing.s6),
                    Text(
                      '${record.inferenceMs!.toStringAsFixed(1)} ms',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10.0,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View scan',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2.0),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 14.0,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
