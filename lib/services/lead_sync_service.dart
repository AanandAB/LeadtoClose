import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lead.dart';

/// A lead as returned by the Cloudflare worker (`GET /api/leads`).
class RemoteLead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String service;
  final String budget;
  final String message;
  final String source;
  final String submittedAt;
  final bool notified;
  final bool synced;

  RemoteLead({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.source,
    required this.submittedAt,
    required this.notified,
    required this.synced,
    this.phone = '',
    this.company = '',
    this.service = '',
    this.budget = '',
  });

  factory RemoteLead.fromJson(Map<String, dynamic> json) => RemoteLead(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        company: json['company']?.toString() ?? '',
        service: json['service']?.toString() ?? '',
        budget: json['budget']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        source: json['source']?.toString() ?? 'Website',
        submittedAt: json['submittedAt']?.toString() ?? '',
        notified: json['notified'] == true,
        synced: json['synced'] == true,
      );
}

class LeadSyncConfig {
  final String baseUrl; // e.g. https://bitnexel-leads.xxx.workers.dev
  final String token; // LEAD_SYNC_TOKEN
  final Duration interval;

  const LeadSyncConfig({
    required this.baseUrl,
    required this.token,
    this.interval = const Duration(seconds: 30),
  });

  bool get isValid => baseUrl.startsWith('http') && token.isNotEmpty;
}

/// Polls the Cloudflare worker for new website leads and converts them into
/// local [Lead]s (source tagged "Website"). Deduplicates by remote lead id.
class LeadSyncService {
  static const String _seenBoxKeyPrefix = 'remote_lead:';

  final http.Client _client = http.Client();
  final Future<bool> Function(Lead lead) importLead;
  final bool Function(String remoteKey) hasSeenRemoteLead;
  final Future<void> Function(String remoteKey) markRemoteLeadSeen;

  Timer? _timer;
  LeadSyncConfig? _config;
  DateTime? _lastSince;
  bool _busy = false;

  LeadSyncService({
    required this.importLead,
    required this.hasSeenRemoteLead,
    required this.markRemoteLeadSeen,
  });

  /// Callbacks the UI can subscribe to.
  void Function(RemoteLead lead)? onNewLead;
  void Function(String error)? onError;
  void Function(DateTime? lastSync)? onSynced;

  DateTime? get lastSync => _lastSince;

  void configure(LeadSyncConfig config) {
    _config = config;
    _timer?.cancel();
    if (!config.isValid) return;
    _timer = Timer.periodic(config.interval, (_) => pollNow());
  }

  void dispose() {
    _timer?.cancel();
    _client.close();
  }

  /// One manual/automatic poll. Returns the number of new leads imported.
  Future<int> pollNow() async {
    final config = _config;
    if (config == null || !config.isValid || _busy) return 0;
    _busy = true;
    var imported = 0;
    try {
      final sinceParam = _lastSince == null
          ? ''
          : '&since=${Uri.encodeComponent(_lastSince!.toIso8601String())}';
      final uri = Uri.parse(
          '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/leads?limit=50$sinceParam');
      final res = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${config.token}',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        onError?.call('Sync failed: HTTP ${res.statusCode}');
        return 0;
      }

      final body = jsonDecode(res.body);
      final leads = (body['leads'] as List? ?? [])
          .map((e) => RemoteLead.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      for (final remote in leads) {
        final key = '$_seenBoxKeyPrefix${remote.id}';
        if (hasSeenRemoteLead(key)) continue;

        final lead = _toLocalLead(remote);
        final ok = await importLead(lead);
        if (ok) {
          imported++;
          await markRemoteLeadSeen(key);
          onNewLead?.call(remote);
          try {
            // Best-effort ack so the dashboard shows it as imported.
            await _client.patch(
              Uri.parse(
                  '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/leads/${remote.id}/ack'),
              headers: {'Authorization': 'Bearer ${config.token}'},
            ).timeout(const Duration(seconds: 10));
          } catch (_) {}
        }
      }

      _lastSince = DateTime.now();
      onSynced?.call(_lastSince);
    } catch (err) {
      onError?.call(err.toString());
    } finally {
      _busy = false;
    }
    return imported;
  }

  Lead _toLocalLead(RemoteLead r) {
    final budget =
        double.tryParse(r.budget.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return Lead(
      id: 'web_${r.id}',
      name: r.name.isEmpty ? 'Website Visitor' : r.name,
      email: r.email,
      phone: r.phone,
      company: r.company,
      source: r.source.startsWith('Website') || r.source.contains('Wizard')
          ? r.source
          : 'Website — ${r.source}',
      stage: LeadStage.newLead,
      score: budget >= 1000000 ? 'hot' : (budget > 0 ? 'warm' : 'cold'),
      estimatedBudget: budget,
      notes: [
        LeadNote(
          text:
              '${r.service.isNotEmpty ? 'Service: ${r.service}. ' : ''}${r.message}',
          timestamp: DateTime.tryParse(r.submittedAt) ?? DateTime.now(),
        ),
      ],
      activities: [
        LeadActivity(
          type: 'note',
          description: 'Auto-imported from ${r.source} via Cloudflare sync',
          timestamp: DateTime.now(),
        ),
      ],
      createdAt: DateTime.tryParse(r.submittedAt) ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastContactedAt: DateTime.tryParse(r.submittedAt) ?? DateTime.now(),
      followUpDate: DateTime.now().add(const Duration(days: 1)),
    );
  }
}
