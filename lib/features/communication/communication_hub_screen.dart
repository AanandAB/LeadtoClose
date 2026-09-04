import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/communication.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class CommunicationHubScreen extends ConsumerStatefulWidget {
  const CommunicationHubScreen({super.key});

  @override
  ConsumerState<CommunicationHubScreen> createState() =>
      _CommunicationHubScreenState();
}

class _CommunicationHubScreenState
    extends ConsumerState<CommunicationHubScreen> {
  String _typeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final communications = ref.watch(communicationsProvider);
    final filtered = _typeFilter == 'all'
        ? communications
        : communications
            .where((c) => c.type.name == _typeFilter)
            .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Messages',
                  style: AppTypography.displayMedium(context)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showComposeDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Message'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _filterBtn('All', 'all'),
              _filterBtn('Email', 'email'),
              _filterBtn('Call', 'call'),
              _filterBtn('Meeting', 'meeting'),
              _filterBtn('Notes', 'note'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No messages yet',
                    subtitle: 'Start a conversation with your client',
                    actionLabel: 'New Message',
                    onAction: () => _showComposeDialog(context),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _buildMessageCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, String value) {
    final selected = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _typeFilter = value),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    selected ? AppColors.primary : AppColors.borderLight),
          ),
          child: Text(label,
              style: AppTypography.label(context).copyWith(
                color: selected
                    ? AppColors.primaryLight
                    : AppColors.textMuted,
                fontSize: 12,
              )),
        ),
      ),
    );
  }

  Widget _buildMessageCard(Communication comm) {
    IconData icon;
    Color color;
    switch (comm.type) {
      case CommunicationType.email:
        icon = Icons.email_outlined;
        color = AppColors.info;
        break;
      case CommunicationType.call:
        icon = Icons.phone_outlined;
        color = AppColors.success;
        break;
      case CommunicationType.meeting:
        icon = Icons.event_outlined;
        color = AppColors.primary;
        break;
      case CommunicationType.note:
        icon = Icons.note_outlined;
        color = AppColors.warning;
        break;
      case CommunicationType.sms:
        icon = Icons.sms_outlined;
        color = AppColors.infoLight;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: comm.isInternal
              ? AppColors.warning.withOpacity(0.2)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comm.type.name.toUpperCase(),
                        style: AppTypography.caption(context).copyWith(
                            color: color,
                            fontWeight: FontWeight.w700)),
                    if (comm.isInternal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('INTERNAL',
                            style: AppTypography.caption(context).copyWith(
                              color: AppColors.warning,
                              fontSize: 8,
                            )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comm.subject.isNotEmpty ? comm.subject : comm.body,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (comm.body.isNotEmpty && comm.subject.isNotEmpty)
                  Text(comm.body,
                      style: AppTypography.bodySmall(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(DateFormat('MMM d').format(comm.createdAt),
              style: AppTypography.caption(context)),
        ],
      ),
    );
  }

  void _showComposeDialog(BuildContext context) {
    String messageType = 'email';
    String? selectedClientId;
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool isInternal = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title:
              Text('New Message', style: AppTypography.heading2(context)),
          content: SizedBox(
            width: 480,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message type
                  Row(
                    children: [
                      _typeChip('Email', 'email', messageType, (v) => setDialogState(() => messageType = v)),
                      const SizedBox(width: 8),
                      _typeChip('Call', 'call', messageType, (v) => setDialogState(() => messageType = v)),
                      const SizedBox(width: 8),
                      _typeChip('Meeting', 'meeting', messageType, (v) => setDialogState(() => messageType = v)),
                      const SizedBox(width: 8),
                      _typeChip('Note', 'note', messageType, (v) => setDialogState(() => messageType = v)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Client
                  Consumer(
                    builder: (context, ref, _) {
                      final clients = ref.watch(clientsProvider);
                      return DropdownButtonFormField<String>(
                        value: selectedClientId,
                        decoration: const InputDecoration(
                          labelText: 'Client',
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                        ),
                        dropdownColor: AppColors.bgCard,
                        items: clients
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.companyName),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedClientId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Subject
                  TextField(
                    controller: subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.subject, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Body
                  TextField(
                    controller: bodyCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Type your message...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Internal toggle
                  Row(
                    children: [
                      Switch(
                        value: isInternal,
                        onChanged: (v) =>
                            setDialogState(() => isInternal = v),
                        activeColor: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text('Internal note',
                          style: AppTypography.body(context)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final comm = Communication(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  clientId: selectedClientId ?? '',
                  type: CommunicationType.values.firstWhere(
                    (e) => e.name == messageType,
                    orElse: () => CommunicationType.email,
                  ),
                  subject: subjectCtrl.text.trim(),
                  body: bodyCtrl.text.trim(),
                  isInternal: isInternal,
                );

                ref
                    .read(communicationsProvider.notifier)
                    .addCommunication(comm);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(
      String label, String value, String current, Function(String) onTap) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Text(label,
            style: AppTypography.label(context).copyWith(
              color: selected
                  ? AppColors.primaryLight
                  : AppColors.textMuted,
              fontSize: 11,
            )),
      ),
    );
  }
}
