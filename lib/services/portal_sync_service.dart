import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/client.dart';
import '../models/project.dart';
import '../models/process_step.dart';

/// Configuration for pushing CRM data (clients/projects/milestones) up to the
/// Bitnexel client portal worker (`POST /api/portal/sync`).
class PortalSyncConfig {
  final String baseUrl; // e.g. https://api.bitnexel.in
  final String token; // PORTAL_SYNC_TOKEN
  final Duration interval;

  const PortalSyncConfig({
    required this.baseUrl,
    required this.token,
    this.interval = const Duration(minutes: 5),
  });

  bool get isValid => baseUrl.startsWith('http') && token.isNotEmpty;
}

/// Result of a single portal sync.
class PortalSyncResult {
  final int clients;
  final int projects;
  final int milestones;
  final bool ok;
  final DateTime syncedAt;

  PortalSyncResult({
    this.clients = 0,
    this.projects = 0,
    this.milestones = 0,
    this.ok = true,
    DateTime? syncedAt,
  }) : syncedAt = syncedAt ?? DateTime.now();
}

/// One-way push of CRM data → the cloud client portal (D1).
///
/// READ-ONLY with respect to local Hive data: it only *reads* clients, projects
/// and milestones and posts them upstream — it never mutates or deletes local
/// records. Running it is therefore safe for existing client data.
class PortalSyncService {
  final http.Client _client = http.Client();

  final List<Client> Function() getClients;
  final List<Project> Function() getProjects;
  final List<Milestone> Function() getMilestones;

  PortalSyncConfig? _config;
  Timer? _timer;
  bool _busy = false;

  void Function(PortalSyncResult result)? onSynced;
  void Function(String error)? onError;

  PortalSyncService({
    required this.getClients,
    required this.getProjects,
    required this.getMilestones,
  });

  DateTime? get lastSync => _config == null ? null : _lastSyncedAt;
  DateTime? _lastSyncedAt;

  void configure(PortalSyncConfig config) {
    _config = config;
    _timer?.cancel();
    if (!config.isValid) return;
    _timer = Timer.periodic(config.interval, (_) => syncNow());
  }

  void dispose() {
    _timer?.cancel();
    _client.close();
  }

  /// One manual/automatic push. Returns the counts upserted upstream.
  Future<PortalSyncResult> syncNow() async {
    final config = _config;
    if (config == null || !config.isValid || _busy) {
      return PortalSyncResult(ok: false);
    }
    _busy = true;
    try {
      final clients = getClients();
      final projects = getProjects();
      final milestones = getMilestones();

      // Map clientId → primary email, so projects can be keyed to a portal login.
      final emailByClientId = <String, String>{};
      for (final c in clients) {
        final email = _primaryEmail(c);
        if (email.isNotEmpty) emailByClientId[c.id] = email;
      }

      final payload = <String, dynamic>{
        'clients': [
          for (final c in clients)
            if (_primaryEmail(c).isNotEmpty)
              {
                'id': c.id,
                'email': _primaryEmail(c),
                'name': _primaryContact(c)?.name ?? c.companyName,
                'company': c.companyName,
                'created_at': c.createdAt.toIso8601String(),
              },
        ],
        'projects': [
          for (final p in projects)
            if (emailByClientId.containsKey(p.clientId))
              {
                'id': p.id,
                'client_email': emailByClientId[p.clientId],
                'name': p.name,
                'category': p.category,
                'status': p.status.name,
                'stage': _stageForStatus(p.status),
                'summary': p.description.isNotEmpty ? p.description : p.name,
                'step': p.step,
                'total_steps': ProcessStepX.total,
                'created_at': p.createdAt.toIso8601String(),
              },
        ],
        'milestones': [
          for (final m in milestones)
            {
              'id': m.id,
              'project_id': m.projectId,
              'name': m.title,
              'status': _milestoneStatus(m),
              'due_date': m.dueDate == null
                  ? null
                  : m.dueDate!.toIso8601String().substring(0, 10),
            },
        ],
      };

      final res = await _client
          .post(
            Uri.parse(
                '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/portal/sync'),
            headers: {
              'Authorization': 'Bearer ${config.token}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        final err = 'Portal sync failed: HTTP ${res.statusCode}';
        onError?.call(err);
        return PortalSyncResult(ok: false);
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final result = PortalSyncResult(
        clients: (body['clients'] as num?)?.toInt() ?? 0,
        projects: (body['projects'] as num?)?.toInt() ?? 0,
        milestones: (body['milestones'] as num?)?.toInt() ?? 0,
        ok: true,
      );
      _lastSyncedAt = DateTime.now();
      onSynced?.call(result);
      return result;
    } catch (err) {
      onError?.call(err.toString());
      return PortalSyncResult(ok: false);
    } finally {
      _busy = false;
    }
  }

  /// Pushes a studio reply to the portal so it appears in the client's message
  /// thread (`POST /api/portal/reply`, token-authed).
  Future<bool> sendPortalReply({
    required String projectId,
    required String clientEmail,
    required String text,
  }) async {
    final config = _config;
    if (config == null || !config.isValid) return false;
    try {
      final res = await _client
          .post(
            Uri.parse(
                '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/portal/reply'),
            headers: {
              'Authorization': 'Bearer ${config.token}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'project_id': projectId,
              'client_email': clientEmail,
              'text': text,
            }),
          )
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// The best contact for portal identity: the contact flagged primary (with an
  /// email), otherwise the first contact that has an email.
  Contact? _primaryContact(Client c) {
    for (final contact in c.contacts) {
      if (contact.isPrimary && contact.email.trim().isNotEmpty) return contact;
    }
    for (final contact in c.contacts) {
      if (contact.email.trim().isNotEmpty) return contact;
    }
    return null;
  }

  String _primaryEmail(Client c) =>
      _primaryContact(c)?.email.trim().toLowerCase() ?? '';

  String _stageForStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'discovery';
      case ProjectStatus.active:
        return 'development';
      case ProjectStatus.onHold:
        return 'on-hold';
      case ProjectStatus.completed:
        return 'launch';
      case ProjectStatus.cancelled:
        return 'cancelled';
    }
  }

  String _milestoneStatus(Milestone m) {
    if (m.isApproved || m.percentage >= 100) return 'done';
    return 'current';
  }
}
