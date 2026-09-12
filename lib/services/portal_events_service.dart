import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/client.dart';
import '../models/communication.dart';
import '../models/project.dart';
import 'portal_sync_service.dart'; // PortalSyncConfig

/// A client action (message / milestone approval) pulled from the portal worker.
class PortalEvent {
  final String id;
  final String clientEmail;
  final String projectId;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  PortalEvent({
    required this.id,
    required this.clientEmail,
    required this.projectId,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  factory PortalEvent.fromJson(Map<String, dynamic> json) => PortalEvent(
        id: json['id']?.toString() ?? '',
        clientEmail: json['client_email']?.toString() ?? '',
        projectId: json['project_id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        payload: (json['payload'] is Map)
            ? Map<String, dynamic>.from(json['payload'] as Map)
            : {},
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
                DateTime.now(),
      );
}

/// Pulls client actions (messages + milestone approvals) from the portal worker
/// and imports them into the local CRM. READ-ONLY with respect to existing
/// data: it only ADDS communications and flips milestone approval flags — it
/// never deletes or overwrites anything else.
class PortalEventsService {
  final http.Client _client = http.Client();

  final List<Client> Function() getClients;
  final Future<void> Function(Communication) saveCommunication;
  final List<Milestone> Function() getMilestones;
  final Future<void> Function(Milestone) saveMilestone;
  final bool Function(String key) hasSeenEvent;
  final Future<void> Function(String key) markEventSeen;

  PortalSyncConfig? _config;
  Timer? _timer;
  bool _busy = false;

  void Function(int imported)? onImported;
  void Function(String error)? onError;

  PortalEventsService({
    required this.getClients,
    required this.saveCommunication,
    required this.getMilestones,
    required this.saveMilestone,
    required this.hasSeenEvent,
    required this.markEventSeen,
  });

  void configure(PortalSyncConfig config) {
    _config = config;
    _timer?.cancel();
    if (!config.isValid) return;
    _timer = Timer.periodic(config.interval, (_) => pullEvents());
  }

  void dispose() {
    _timer?.cancel();
    _client.close();
  }

  /// One manual/automatic pull. Returns the number of events imported.
  Future<int> pullEvents() async {
    final config = _config;
    if (config == null || !config.isValid || _busy) return 0;
    _busy = true;
    var imported = 0;
    try {
      final res = await _client
          .get(
            Uri.parse(
                '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/portal/events'),
            headers: {
              'Authorization': 'Bearer ${config.token}',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        onError?.call('Portal events pull failed: HTTP ${res.statusCode}');
        return 0;
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final events = (body['events'] as List? ?? [])
          .map((e) => PortalEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      for (final event in events) {
        if (!hasSeenEvent('portal_event:${event.id}')) {
          final ok = await _import(event);
          if (ok) {
            imported++;
            await markEventSeen('portal_event:${event.id}');
          }
        }
        await _ack(config, event.id);
      }

      onImported?.call(imported);
    } catch (err) {
      onError?.call(err.toString());
    } finally {
      _busy = false;
    }
    return imported;
  }

  Future<void> _ack(PortalSyncConfig config, String id) async {
    try {
      await _client
          .patch(
            Uri.parse(
                '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/portal/events/$id/ack'),
            headers: {'Authorization': 'Bearer ${config.token}'},
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  String? _clientIdForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final c in getClients()) {
      for (final contact in c.contacts) {
        if (contact.email.trim().toLowerCase() == normalized) return c.id;
      }
    }
    return null;
  }

  Future<bool> _import(PortalEvent event) async {
    if (event.type == 'message') {
      final text = (event.payload['text'] ?? '').toString().trim();
      if (text.isEmpty) return false;
      final comm = Communication(
        id: 'portal_${event.id}',
        clientId: _clientIdForEmail(event.clientEmail) ?? '',
        projectId: event.projectId,
        type: CommunicationType.note,
        direction: 'inbound',
        subject: 'Portal message',
        body: text,
        contactEmail: event.clientEmail,
        isInternal: false,
        createdAt: event.createdAt,
      );
      await saveCommunication(comm);
      return true;
    }

    if (event.type == 'milestone_approval') {
      final milestoneId = (event.payload['milestone_id'] ?? '').toString();
      if (milestoneId.isEmpty) return true; // nothing to do — ack it
      for (final m in getMilestones()) {
        if (m.id == milestoneId && !m.isApproved) {
          await saveMilestone(m.copyWith(isApproved: true));
          return true;
        }
      }
      return true; // already approved / not found — ack anyway
    }

    return true; // unknown type — ack to avoid re-processing
  }
}
