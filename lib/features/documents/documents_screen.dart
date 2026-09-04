import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/document.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _view = 'grid';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider);
    final filtered = _filter == 'all'
        ? documents
        : documents.where((d) => d.mimeType.contains(_filter)).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Documents', style: AppTypography.displayMedium(context)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    _viewBtn('grid', Icons.grid_view_rounded),
                    _viewBtn('list', Icons.view_list_rounded),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _filterBtn('All', 'all'),
              _filterBtn('PDF', 'pdf'),
              _filterBtn('Images', 'image'),
              _filterBtn('Docs', 'document'),
              _filterBtn('Sheets', 'spreadsheet'),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.folder_copy_outlined,
                    title: 'No documents yet',
                    subtitle: 'Upload files to your vault',
                    actionLabel: 'Upload File',
                    onAction: () {},
                  )
                : _view == 'grid'
                    ? _buildGridView(filtered)
                    : _buildListView(filtered),
          ),
        ],
      ),
    );
  }

  Widget _viewBtn(String view, IconData icon) {
    final selected = _view == view;
    return GestureDetector(
      onTap: () => setState(() => _view = view),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: selected ? AppColors.primaryLight : AppColors.textMuted),
      ),
    );
  }

  Widget _filterBtn(String label, String value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
          ),
          child: Text(label, style: AppTypography.label(context).copyWith(
            color: selected ? AppColors.primaryLight : AppColors.textMuted, fontSize: 12,
          )),
        ),
      ),
    );
  }

  Widget _buildGridView(List<AppDocument> docs) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: docs.length,
      itemBuilder: (context, i) => _buildGridItem(docs[i]),
    );
  }

  Widget _buildGridItem(AppDocument doc) {
    final iconData = _getFileIcon(doc.icon);
    final color = _getFileColor(doc.icon);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(doc.name, style: AppTypography.body(context).copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 12,
          ), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(doc.sizeDisplay, style: AppTypography.caption(context)),
        ],
      ),
    );
  }

  Widget _buildListView(List<AppDocument> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final doc = docs[i];
        final iconData = _getFileIcon(doc.icon);
        final color = _getFileColor(doc.icon);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.name, style: AppTypography.body(context).copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                    )),
                    Text('${doc.sizeDisplay} · v${doc.version}', style: AppTypography.caption(context)),
                  ],
                ),
              ),
              Text(DateFormat('MMM d').format(doc.createdAt), style: AppTypography.caption(context)),
            ],
          ),
        );
      },
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'image': return Icons.image_outlined;
      case 'video': return Icons.videocam_outlined;
      case 'archive': return Icons.archive_outlined;
      case 'spreadsheet': return Icons.table_chart_outlined;
      case 'document': return Icons.description_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileColor(String type) {
    switch (type) {
      case 'pdf': return AppColors.danger;
      case 'image': return AppColors.success;
      case 'video': return AppColors.primary;
      case 'archive': return AppColors.warning;
      case 'spreadsheet': return AppColors.success;
      case 'document': return AppColors.info;
      default: return AppColors.textMuted;
    }
  }
}
