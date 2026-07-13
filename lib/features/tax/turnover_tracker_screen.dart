
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class TurnoverTrackerScreen extends ConsumerStatefulWidget {
  const TurnoverTrackerScreen({super.key});

  @override
  ConsumerState<TurnoverTrackerScreen> createState() => _TurnoverTrackerScreenState();
}

class _TurnoverTrackerScreenState extends ConsumerState<TurnoverTrackerScreen> {
  final double _ytdTurnover = 1700000;
  final bool _hasInterStateClient = true;
  final bool _isGstRegistered = false;

  @override
  Widget build(BuildContext context) {
    final threshold = 2000000.0; // 20L
    final pct = (_ytdTurnover / threshold).clamp(0.0, 1.0);
    final isWarning = _ytdTurnover >= threshold * 0.75;
    final isCritical = _ytdTurnover >= threshold;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/tax-calendar')),
        title: Text('Turnover Tracker', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // GST threshold gauge
          if (!_isGstRegistered) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCritical
                      ? [AppColors.danger.withOpacity(0.2), AppColors.danger.withOpacity(0.05)]
                      : isWarning
                          ? [AppColors.warning.withOpacity(0.2), AppColors.warning.withOpacity(0.05)]
                          : [AppColors.success.withOpacity(0.15), AppColors.success.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isCritical ? AppColors.danger.withOpacity(0.3) : isWarning ? AppColors.warning.withOpacity(0.3) : AppColors.success.withOpacity(0.3)),
              ),
              child: Column(children: [
                Icon(isCritical ? Icons.warning : isWarning ? Icons.trending_up : Icons.check_circle,
                    size: 48, color: isCritical ? AppColors.danger : isWarning ? AppColors.warning : AppColors.success),
                const SizedBox(height: 12),
                Text(isCritical ? 'GST THRESHOLD BREACHED' : isWarning ? 'APPROACHING GST THRESHOLD' : 'Well Below Threshold',
                    style: AppTypography.heading2(context).copyWith(
                      color: isCritical ? AppColors.danger : isWarning ? AppColors.warning : AppColors.success,
                    )),
                const SizedBox(height: 8),
                Text('\u{20B9}${_formatAmount(_ytdTurnover)} of \u{20B9}${_formatAmount(threshold)}',
                    style: AppTypography.heading1(context)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct, minHeight: 12,
                    backgroundColor: AppColors.bgSurface,
                    valueColor: AlwaysStoppedAnimation(
                      isCritical ? AppColors.danger : isWarning ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(pct * 100).toStringAsFixed(1)}% of GST registration threshold',
                    style: AppTypography.bodySmall(context)),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          // Inter-state flag
          if (_hasInterStateClient && !_isGstRegistered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.error, color: AppColors.danger, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('INTER-STATE CLIENT DETECTED', style: AppTypography.label(context).copyWith(color: AppColors.danger)),
                  Text('GST registration is mandatory immediately — regardless of turnover. This is the rule most freelancers miss.',
                      style: AppTypography.body(context).copyWith(fontSize: 12)),
                ])),
              ]),
            ),
          const SizedBox(height: 24),

          // Turnover breakdown
          _sectionHeader('Turnover Breakdown'),
          const SizedBox(height: 8),
          _infoRow('Year-to-Date Gross Receipts', '\u{20B9}${_formatAmount(_ytdTurnover)}'),
          _infoRow('GST Registration Threshold', '\u{20B9}20,00,000', valueColor: AppColors.warning),
          _infoRow('Remaining Headroom', '\u{20B9}${_formatAmount((threshold - _ytdTurnover).clamp(0, double.infinity))}', valueColor: _ytdTurnover >= threshold ? AppColors.danger : AppColors.success),
          _infoRow('PAN-Level Aggregate', 'All clients combined', muted: true),
          _infoRow('Inter-State Client Present', _hasInterStateClient ? 'YES — Registration Mandatory' : 'No', valueColor: _hasInterStateClient ? AppColors.danger : null),
          _infoRow('GST Registered', _isGstRegistered ? 'Yes' : 'No', valueColor: _isGstRegistered ? AppColors.success : AppColors.warning),
          const SizedBox(height: 24),

          _sectionHeader('What Happens If You Cross?'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _bullet('Register for GST within 30 days of crossing \u{20B9}20L'),
              _bullet('Start charging GST on all invoices (18% for services)'),
              _bullet('File monthly GSTR-1 and GSTR-3B returns'),
              _bullet('File annual GSTR-9 return'),
              _bullet('Collect GST from clients and deposit with government'),
              _bullet('Penalty for non-registration: 100% of tax due (minimum)'),
            ]),
          ),
          const SizedBox(height: 16),

          if (!_isGstRegistered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.lightbulb, color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Tip: If you have ANY inter-state client, register for GST immediately — the \u{20B9}20L exemption doesn\'t apply.',
                  style: AppTypography.body(context).copyWith(fontSize: 12),
                )),
              ]),
            ),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTypography.heading2(context).copyWith(color: AppColors.primaryLight));
  }

  Widget _infoRow(String label, String value, {Color? valueColor, bool muted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTypography.body(context).copyWith(color: muted ? AppColors.textMuted : null)),
        Text(value, style: AppTypography.body(context).copyWith(
          color: valueColor ?? (muted ? AppColors.textMuted : AppColors.textPrimary),
          fontWeight: FontWeight.w600,
        )),
      ]),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('  -  ', style: TextStyle(color: AppColors.textMuted)),
        Expanded(child: Text(text, style: AppTypography.body(context).copyWith(fontSize: 12))),
      ]),
    );
  }

  String _formatAmount(double amt) {
    if (amt >= 10000000) return '${(amt / 10000000).toStringAsFixed(2)} Cr';
    if (amt >= 100000) return '${(amt / 100000).toStringAsFixed(2)} L';
    if (amt >= 1000) return '${(amt / 1000).toStringAsFixed(1)}K';
    return amt.toStringAsFixed(0);
  }
}
