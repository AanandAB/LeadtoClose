import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../../services/communication_service.dart';

class CommunicationScreen extends ConsumerStatefulWidget {
  final String leadId;
  const CommunicationScreen({super.key, required this.leadId});

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen> {
  List<MessageTemplate> _messages = [];
  bool _loading = true;
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  void _generate() {
    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final profile = ref.read(businessProfileProvider);
    if (profile == null) return;

    final quotes = ref.read(quotesProvider(widget.leadId));
    final projectProfile = lead.projectProfile;
    final complianceItems = ref.read(complianceChecklistProvider);

    final service = CommunicationService();
    _messages = service.generateAll(
      lead: lead, profile: profile,
      projectProfile: projectProfile,
      quote: quotes.isNotEmpty ? quotes.first : null,
      complianceItems: complianceItems,
    );

    setState(() => _loading = false);
  }

  List<MessageTemplate> get _filtered {
    if (_activeTab == 'email') return _messages.where((m) => m.stageLabel.contains('Sent') || m.stageLabel.contains('Ready') || m.stageLabel.contains('Reminder') || m.stageLabel.contains('Received')).toList();
    if (_activeTab == 'whatsapp') return _messages;
    if (_activeTab == 'payment') return _messages.where((m) => m.stageLabel.contains('Overdue') || m.stageLabel.contains('Received') || m.stageLabel.contains('Invoice')).toList();
    return _messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Messages', style: AppTypography.heading2(context)),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        // Filter tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.bgMid,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _tab('All', 'all'), _tab('Email', 'email'),
              _tab('WhatsApp', 'whatsapp'), _tab('Payment', 'payment'),
            ]),
          ),
        ),
        // Message list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _messageCard(_filtered[i]),
          ),
        ),
      ]),
    );
  }

  Widget _tab(String label, String key) {
    final active = _activeTab == key;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppTypography.caption(context).copyWith(
          color: active ? Colors.white : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
    );
  }

  Widget _messageCard(MessageTemplate msg) {
    final isEmail = msg.stageLabel.contains('Sent') || msg.stageLabel.contains('Ready') || msg.stageLabel.contains('Reminder') || msg.stageLabel.contains('Received') || msg.stageLabel.contains('Summary') || msg.stageLabel.contains('Onboarding') || msg.stageLabel.contains('Introduction') || msg.stageLabel.contains('Discuss') || msg.stageLabel.contains('Follow-up') || msg.stageLabel.contains('Thank You') || msg.stageLabel.contains('Review') || msg.stageLabel.contains('Invoice');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: const Border(), collapsedShape: const Border(),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.email_outlined, size: 18, color: AppColors.primaryLight),
        ),
        title: Text(msg.stageLabel, style: AppTypography.body(context).copyWith(
          fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13,
        )),
        subtitle: Text('Email + WhatsApp templates', style: AppTypography.caption(context)),
        children: [
          // Email section
          Row(children: [
            const Icon(Icons.email, size: 14, color: AppColors.primaryLight),
            const SizedBox(width: 6),
            Text('EMAIL', style: AppTypography.caption(context).copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Text('Subject: ${msg.emailSubject}', style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: SelectableText(msg.emailBody, style: AppTypography.body(context).copyWith(fontSize: 12, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _actionChip('Copy Email', Icons.copy, () {
              Clipboard.setData(ClipboardData(text: 'Subject: ${msg.emailSubject}\n\n${msg.emailBody}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied to clipboard')));
            }),
          ]),
          const SizedBox(height: 16),

          // WhatsApp section
          Row(children: [
            const Icon(Icons.chat, size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text('WHATSAPP', style: AppTypography.caption(context).copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.15)),
            ),
            child: SelectableText(msg.whatsappBody, style: AppTypography.body(context).copyWith(fontSize: 12, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _actionChip('Copy WhatsApp', Icons.copy, () {
              Clipboard.setData(ClipboardData(text: msg.whatsappBody));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp message copied')));
            }),
          ]),
        ],
      ),
    );
  }

  Widget _actionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: AppColors.primaryLight),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption(context).copyWith(color: AppColors.primaryLight)),
        ]),
      ),
    );
  }
}
