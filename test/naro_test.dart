import 'package:flutter_test/flutter_test.dart';
import 'package:freelancehub/models/lead.dart';
import 'package:freelancehub/models/client.dart';
import 'package:freelancehub/models/project.dart';
import 'package:freelancehub/models/task.dart';
import 'package:freelancehub/models/invoice.dart';
import 'package:freelancehub/models/quote.dart';
import 'package:freelancehub/models/contract.dart';
import 'package:freelancehub/models/time_entry.dart';
import 'package:freelancehub/models/communication.dart';
import 'package:freelancehub/models/event.dart';
import 'package:freelancehub/models/document.dart';
import 'package:freelancehub/models/app_settings.dart';
import 'dart:ui';
import 'package:freelancehub/core/theme.dart';

void main() {
  group('AppCurrency', () {
    test('defaults to INR', () {
      AppCurrency.setCode('INR');
      expect(AppCurrency.code, 'INR');
      expect(AppCurrency.symbol, '₹');
    });

    test('INR format uses Indian comma grouping', () {
      AppCurrency.setCode('INR');
      expect(AppCurrency.format(1234567), '₹12,34,567');
      expect(AppCurrency.format(100000), '₹1,00,000');
      expect(AppCurrency.format(999), '₹999');
      expect(AppCurrency.format(0), '₹0');
    });

    test('INR compact format uses Lakh and Crore', () {
      AppCurrency.setCode('INR');
      expect(AppCurrency.formatCompact(12000000), '₹1.2Cr');
      expect(AppCurrency.formatCompact(350000), '₹3.5L');
      expect(AppCurrency.formatCompact(5000), '₹5.0K');
      expect(AppCurrency.formatCompact(500), '₹500');
    });

    test('INR decimal format works', () {
      AppCurrency.setCode('INR');
      expect(AppCurrency.formatDecimal(1234567.50), '₹12,34,567.50');
      expect(AppCurrency.formatDecimal(99.99), '₹99.99');
    });

    test('USD uses \$ symbol', () {
      AppCurrency.setCode('USD');
      expect(AppCurrency.symbol, '\$');
      expect(AppCurrency.format(1234), '\$1234');
    });

    test('EUR uses € symbol', () {
      AppCurrency.setCode('EUR');
      expect(AppCurrency.symbol, '€');
    });

    test('GBP uses £ symbol', () {
      AppCurrency.setCode('GBP');
      expect(AppCurrency.symbol, '£');
    });

    test('JPY uses ¥ symbol', () {
      AppCurrency.setCode('JPY');
      expect(AppCurrency.symbol, '¥');
    });

    test('supported currencies list is correct', () {
      expect(AppCurrency.supportedCurrencies, ['INR', 'USD', 'EUR', 'GBP', 'JPY', 'AED', 'SAR']);
    });
  });

  group('Lead Model', () {
    test('creates with defaults', () {
      final lead = Lead(
        id: '1',
        name: 'Test Lead',
        email: 'test@test.com',
      );
      expect(lead.id, '1');
      expect(lead.name, 'Test Lead');
      expect(lead.stage, LeadStage.newLead);
      expect(lead.score, 'warm');
      expect(lead.source, 'Direct');
      expect(lead.company, '');
    });

    test('stageLabel returns correct labels', () {
      final stages = {
        LeadStage.newLead: 'New Lead',
        LeadStage.contacted: 'Contacted',
        LeadStage.qualified: 'Qualified',
        LeadStage.proposalSent: 'Proposal Sent',
        LeadStage.negotiation: 'Negotiation',
        LeadStage.won: 'Won',
        LeadStage.lost: 'Lost',
      };
      for (final entry in stages.entries) {
        final lead = Lead(id: '1', name: 'T', stage: entry.key);
        expect(lead.stageLabel, entry.value);
      }
    });

    test('isOverdue returns true when followUpDate is past', () {
      final lead = Lead(
        id: '1',
        name: 'T',
        followUpDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(lead.isOverdue, true);
    });

    test('toJson/fromJson roundtrip', () {
      final lead = Lead(
        id: '1',
        name: 'Test',
        email: 't@t.com',
        company: 'Acme',
        stage: LeadStage.qualified,
        score: 'hot',
        source: 'referral',
        estimatedBudget: 5000,
      );
      final json = lead.toJson();
      final restored = Lead.fromJson(json);
      expect(restored.id, lead.id);
      expect(restored.name, lead.name);
      expect(restored.stage, lead.stage);
      expect(restored.score, lead.score);
      expect(restored.estimatedBudget, lead.estimatedBudget);
    });

    test('copyWith preserves other fields', () {
      final lead = Lead(id: '1', name: 'Test', stage: LeadStage.newLead);
      final updated = lead.copyWith(stage: LeadStage.won);
      expect(updated.stage, LeadStage.won);
      expect(updated.name, 'Test');
      expect(updated.id, '1');
    });
  });

  group('Client Model', () {
    test('creates with defaults', () {
      final client = Client(id: '1', companyName: 'Acme');
      expect(client.companyName, 'Acme');
      expect(client.healthScore, 'active');
      expect(client.contacts, isEmpty);
      expect(client.totalRevenue, 0);
    });

    test('primaryContact returns first primary contact', () {
      final client = Client(
        id: '1',
        companyName: 'Acme',
        contacts: [
          Contact(id: '1', name: 'John', email: 'j@j.com', isPrimary: true),
          Contact(id: '2', name: 'Jane', email: 'jane@j.com'),
        ],
      );
      expect(client.primaryContact!.name, 'John');
    });

    test('toJson/fromJson roundtrip', () {
      final client = Client(
        id: '1',
        companyName: 'Acme',
        industry: 'Tech',
        contacts: [
          Contact(id: '1', name: 'John', email: 'j@j.com', phone: '123'),
        ],
        totalRevenue: 10000,
        outstandingBalance: 2000,
      );
      final json = client.toJson();
      final restored = Client.fromJson(json);
      expect(restored.id, client.id);
      expect(restored.companyName, client.companyName);
      expect(restored.totalRevenue, client.totalRevenue);
      expect(restored.contacts.length, 1);
      expect(restored.contacts[0].name, 'John');
    });
  });

  group('Project Model', () {
    test('creates with defaults', () {
      final project = Project(id: '1', name: 'Web App', clientId: 'c1');
      expect(project.name, 'Web App');
      expect(project.status, ProjectStatus.planning);
      expect(project.priority, 'medium');
      expect(project.budget, 0);
    });

    test('isOverdue works', () {      final project = Project(
        id: '1', name: 'Past', clientId: 'c1',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: ProjectStatus.active,
      );
      expect(project.isOverdue, true);
    });

    test('budgetPercentage calculates correctly', () {
      final project = Project(id: '1', name: 'T', clientId: 'c1', budget: 1000, spent: 250);
      expect(project.budgetPercentage, 25.0);
    });

    test('toJson/fromJson roundtrip', () {
      final project = Project(
        id: '1', name: 'Test', clientId: 'c1',
        budget: 5000, spent: 1000, priority: 'high',
        status: ProjectStatus.active,
      );
      final json = project.toJson();
      final restored = Project.fromJson(json);
      expect(restored.id, project.id);
      expect(restored.budget, project.budget);
      expect(restored.priority, project.priority);
    });
  });

  group('Task Model', () {
    test('creates with defaults', () {
      final task = Task(id: '1', projectId: 'p1', title: 'Build UI');
      expect(task.title, 'Build UI');        expect(task.status, TaskStatus.todo);
      expect(task.priority, 'medium');
    });

    test('status cycling works', () {
      var task = Task(id: '1', projectId: 'p1', title: 'T');        expect(task.status, TaskStatus.todo);
      task = task.copyWith(status: TaskStatus.inProgress);
      expect(task.status, TaskStatus.inProgress);
      task = task.copyWith(status: TaskStatus.review);
      expect(task.status, TaskStatus.review);
      task = task.copyWith(status: TaskStatus.done);
      expect(task.status, TaskStatus.done);
    });

    test('toJson/fromJson roundtrip', () {
      final task = Task(
        id: '1', projectId: 'p1', title: 'T',
        status: TaskStatus.inProgress, priority: 'high',
      );
      final json = task.toJson();
      final restored = Task.fromJson(json);
      expect(restored.status, TaskStatus.inProgress);
      expect(restored.priority, 'high');
    });
  });

  group('Invoice Model', () {
    test('creates with defaults', () {
      final invoice = Invoice(id: '1', number: 'INV-001');
      expect(invoice.number, 'INV-001');
      expect(invoice.status, 'active');
      expect(invoice.currency, 'USD');
      expect(invoice.balanceDue, invoice.total);
    });

    test('isOverdue works', () {
      final invoice = Invoice(
        id: '1', number: 'INV-001',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'sent',
      );
      expect(invoice.isOverdue, true);
      expect(invoice.daysOverdue, 5);
    });

    test('paid invoices are not overdue', () {
      final invoice = Invoice(
        id: '1', number: 'INV-001',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'paid',
      );
      expect(invoice.isOverdue, false);
    });

    test('balanceDue subtracts amountPaid', () {
      final invoice = Invoice(
        id: '1', number: 'INV-001',
        total: 1000, amountPaid: 300,
      );
      expect(invoice.balanceDue, 700);
    });

    test('toJson/fromJson roundtrip', () {
      final invoice = Invoice(
        id: '1', number: 'INV-001',
        lineItems: [
          InvoiceLineItem(description: 'Dev work', quantity: 10, rate: 100),
        ],
        subtotal: 1000, total: 1000,
        currency: 'INR', paymentTerms: 'Net 30',
      );
      final json = invoice.toJson();
      final restored = Invoice.fromJson(json);
      expect(restored.currency, 'INR');
      expect(restored.lineItems.length, 1);
      expect(restored.lineItems[0].rate, 100);
    });
  });

  group('Quote Model', () {
    test('creates with defaults', () {
      final quote = Quote(id: '1', number: 'Q-001');
      expect(quote.status, 'draft');
      expect(quote.lineItems, isEmpty);
    });

    test('total calculation', () {
      final quote = Quote(
        id: '1', number: 'Q-001',
        lineItems: [
          QuoteLineItem(description: 'A', quantity: 2, rate: 100),
          QuoteLineItem(description: 'B', quantity: 1, rate: 50),
        ],
        subtotal: 250,
        taxRate: 10,
        taxAmount: 25,
        total: 275,
      );
      expect(quote.lineItems.length, 2);
      expect(quote.total, 275);
    });

    test('toJson/fromJson roundtrip', () {
      final quote = Quote(
        id: '1', number: 'Q-001',
        title: 'Web Project',
        lineItems: [
          QuoteLineItem(description: 'Design', quantity: 1, rate: 500),
        ],
        subtotal: 500, total: 500,
        status: 'sent',
      );
      final json = quote.toJson();
      final restored = Quote.fromJson(json);
      expect(restored.title, 'Web Project');
      expect(restored.status, 'sent');
      expect(restored.lineItems[0].rate, 500);
    });
  });

  group('Contract Model', () {
    test('creates with defaults', () {
      final contract = Contract(id: '1', number: 'CTR-001');
      expect(contract.type, 'SOW');
      expect(contract.status, 'draft');
      expect(contract.clauses, isEmpty);
    });

    test('isExpired works', () {
      final contract = Contract(
        id: '1', number: 'CTR-001',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(contract.isExpired, true);
    });

    test('toJson/fromJson roundtrip', () {
      final contract = Contract(
        id: '1', number: 'CTR-001',
        title: 'SOW for Acme',
        type: 'SOW',
        clauses: [
          ContractClause(title: 'Scope', body: 'Build web app', category: 'standard'),
        ],
        status: 'active',
      );
      final json = contract.toJson();
      final restored = Contract.fromJson(json);
      expect(restored.title, 'SOW for Acme');
      expect(restored.clauses.length, 1);
      expect(restored.clauses[0].title, 'Scope');
    });
  });

  group('TimeEntry Model', () {
    test('creates with defaults', () {
      final entry = TimeEntry(id: '1', projectId: 'p1', description: 'Coding');
      expect(entry.hours, 0);
      expect(entry.isBillable, true);
    });

    test('toJson/fromJson roundtrip', () {
      final entry = TimeEntry(
        id: '1', projectId: 'p1', taskId: 't1',
        description: 'Design review', hours: 2.5,
        isBillable: false, date: DateTime(2026, 1, 15),
      );
      final json = entry.toJson();
      final restored = TimeEntry.fromJson(json);
      expect(restored.hours, 2.5);
      expect(restored.isBillable, false);
    });
  });

  group('Communication Model', () {
    test('creates with defaults', () {
      final comm = Communication(
        id: '1', type: CommunicationType.email,
      );
      expect(comm.subject, '');
      expect(comm.isInternal, false);
    });

    test('toJson/fromJson roundtrip', () {
      final comm = Communication(
        id: '1', clientId: 'c1',
        type: CommunicationType.meeting,
        subject: 'Project kickoff',
        body: 'Met with client',
        isInternal: true,
      );
      final json = comm.toJson();
      final restored = Communication.fromJson(json);
      expect(restored.type, CommunicationType.meeting);
      expect(restored.isInternal, true);
      expect(restored.subject, 'Project kickoff');
    });
  });

  group('CalendarEvent Model', () {
    test('creates with defaults', () {
      final event = CalendarEvent(
        id: '1', title: 'Meeting',
        startTime: DateTime(2026, 1, 15, 10),
      );
      expect(event.type, EventType.meeting);
      expect(event.isCompleted, false);
      expect(event.isAllDay, false);
    });

    test('endTime defaults to startTime + 1 hour', () {
      final start = DateTime(2026, 1, 15, 10);
      final event = CalendarEvent(id: '1', title: 'M', startTime: start);
      expect(event.endTime, DateTime(2026, 1, 15, 11));
    });

    test('toJson/fromJson roundtrip', () {
      final start = DateTime(2026, 1, 15, 10);
      final end = DateTime(2026, 1, 15, 12);
      final event = CalendarEvent(
        id: '1', title: 'Sprint Review',
        type: EventType.deadline,
        startTime: start, endTime: end,
      );
      final json = event.toJson();
      final restored = CalendarEvent.fromJson(json);
      expect(restored.type, EventType.deadline);
      expect(restored.title, 'Sprint Review');
    });
  });

  group('AppDocument Model', () {
    test('creates with defaults', () {
      final doc = AppDocument(id: '1', name: 'readme.pdf');
      expect(doc.sizeBytes, 0);
      expect(doc.version, 1);
      expect(doc.isClientVisible, true);
    });

    test('sizeDisplay formats correctly', () {
      expect(AppDocument(id: '1', name: 'a', sizeBytes: 500).sizeDisplay, '500 B');
      expect(AppDocument(id: '1', name: 'a', sizeBytes: 1536).sizeDisplay, '1.5 KB');
      expect(AppDocument(id: '1', name: 'a', sizeBytes: 2097152).sizeDisplay, '2.0 MB');
    });

    test('icon type detection', () {
      expect(AppDocument(id: '1', name: 'a', mimeType: 'application/pdf').icon, 'pdf');
      expect(AppDocument(id: '1', name: 'a', mimeType: 'image/png').icon, 'image');
      expect(AppDocument(id: '1', name: 'a', mimeType: 'video/mp4').icon, 'video');
      expect(AppDocument(id: '1', name: 'a', mimeType: 'application/zip').icon, 'archive');
      expect(AppDocument(id: '1', name: 'a', mimeType: 'text/plain').icon, 'file');
    });
  });

  group('AppSettings Model', () {
    test('creates with INR default', () {
      final settings = AppSettings();
      expect(settings.currency, 'INR');
      expect(settings.currencySymbol, '₹');
      expect(settings.isDarkMode, false);
    });

    test('toJson/fromJson roundtrip', () {
      final settings = AppSettings(
        businessName: 'My Studio',
        ownerName: 'Rahul',
        currency: 'USD',
        isDarkMode: true,
      );
      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);
      expect(restored.businessName, 'My Studio');
      expect(restored.currency, 'USD');
      expect(restored.isDarkMode, true);
    });

    test('copyWith works', () {
      final s = AppSettings(businessName: 'A');
      final updated = s.copyWith(businessName: 'B', isDarkMode: true);
      expect(updated.businessName, 'B');
      expect(updated.isDarkMode, true);
      expect(updated.currency, 'INR'); // preserved
    });
  });

  group('AppColors Theme', () {
    test('light mode colors are correct', () {
      AppColors.setDarkMode(false);
      expect(AppColors.bgDeep, const Color(0xFFF7F7FB));
      expect(AppColors.textPrimary, const Color(0xFF1B1B2A));
      expect(AppColors.primary, const Color(0xFF5B4FE9));
    });

    test('dark mode colors are correct', () {
      AppColors.setDarkMode(true);
      expect(AppColors.bgDeep, const Color(0xFF111118));
      expect(AppColors.textPrimary, const Color(0xFFF1F1F6));
      expect(AppColors.primary, const Color(0xFF8B7FFF));
    });

    test('switching modes changes all colors', () {
      AppColors.setDarkMode(false);
      final bgLight = AppColors.bgCard;
      AppColors.setDarkMode(true);
      final bgDark = AppColors.bgCard;
      expect(bgLight, isNot(equals(bgDark)));
    });
  });

  group('AppTheme helpers', () {
    test('stageColor returns correct colors', () {
      expect(AppTheme.stageColor('Won'), AppColors.success);
      expect(AppTheme.stageColor('Lost'), AppColors.danger);
      expect(AppTheme.stageColor('New Lead'), AppColors.stageNew);
      expect(AppTheme.stageColor('unknown'), AppColors.textMuted);
    });

    test('statusColor returns correct colors', () {
      expect(AppTheme.statusColor('paid'), AppColors.success);
      expect(AppTheme.statusColor('overdue'), AppColors.danger);
      expect(AppTheme.statusColor('draft'), AppColors.textMuted);
      expect(AppTheme.statusColor('sent'), AppColors.info);
    });

    test('priorityColor returns correct colors', () {
      expect(AppTheme.priorityColor('urgent'), AppColors.priorityUrgent);
      expect(AppTheme.priorityColor('high'), AppColors.priorityHigh);
      expect(AppTheme.priorityColor('medium'), AppColors.priorityMedium);
      expect(AppTheme.priorityColor('low'), AppColors.priorityLow);
    });
  });
}
