import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/lead.dart';
import 'models/client.dart';
import 'models/project.dart';
import 'models/task.dart';
import 'models/invoice.dart';
import 'models/quote.dart';
import 'models/contract.dart';
import 'models/time_entry.dart';
import 'models/document.dart';
import 'models/communication.dart';
import 'models/event.dart';
import 'models/app_settings.dart';
import 'services/storage_service.dart';

// Storage
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized before use');
});

// ============ Settings ============
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;
  SettingsNotifier(this._storage) : super(_storage.getSettings());

  Future<void> save(AppSettings settings) async {
    await _storage.saveSettings(settings);
    state = settings;
  }
}

// ============ Leads ============
final leadsProvider =
    StateNotifierProvider<LeadsNotifier, List<Lead>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LeadsNotifier(storage);
});

class LeadsNotifier extends StateNotifier<List<Lead>> {
  final StorageService _storage;
  LeadsNotifier(this._storage) : super(_storage.getAllLeads());

  void refresh() {
    state = _storage.getAllLeads();
  }

  Future<void> addLead(Lead lead) async {
    await _storage.saveLead(lead);
    refresh();
  }

  Future<void> updateLead(Lead lead) async {
    await _storage.saveLead(lead);
    refresh();
  }

  Future<void> deleteLead(String id) async {
    await _storage.deleteLead(id);
    refresh();
  }

  List<Lead> getByStage(LeadStage stage) {
    return state.where((l) => l.stage == stage).toList();
  }
}

// ============ Clients ============
final clientsProvider =
    StateNotifierProvider<ClientsNotifier, List<Client>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ClientsNotifier(storage);
});

class ClientsNotifier extends StateNotifier<List<Client>> {
  final StorageService _storage;
  ClientsNotifier(this._storage) : super(_storage.getAllClients());

  void refresh() {
    state = _storage.getAllClients();
  }

  Future<void> addClient(Client client) async {
    await _storage.saveClient(client);
    refresh();
  }

  Future<void> updateClient(Client client) async {
    await _storage.saveClient(client);
    refresh();
  }

  Future<void> deleteClient(String id) async {
    await _storage.deleteClient(id);
    refresh();
  }
}

// ============ Projects ============
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProjectsNotifier(storage);
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final StorageService _storage;
  ProjectsNotifier(this._storage) : super(_storage.getAllProjects());

  void refresh() {
    state = _storage.getAllProjects();
  }

  Future<void> addProject(Project project) async {
    await _storage.saveProject(project);
    refresh();
  }

  Future<void> updateProject(Project project) async {
    await _storage.saveProject(project);
    refresh();
  }

  Future<void> deleteProject(String id) async {
    await _storage.deleteProject(id);
    refresh();
  }

  List<Project> getByStatus(ProjectStatus status) {
    return state.where((p) => p.status == status).toList();
  }

  List<Project> getByClient(String clientId) {
    return state.where((p) => p.clientId == clientId).toList();
  }
}

// ============ Tasks ============
final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TasksNotifier(storage);
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final StorageService _storage;
  TasksNotifier(this._storage) : super(_storage.getAllTasks());

  void refresh() {
    state = _storage.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    await _storage.saveTask(task);
    refresh();
  }

  Future<void> updateTask(Task task) async {
    await _storage.saveTask(task);
    refresh();
  }

  Future<void> deleteTask(String id) async {
    await _storage.deleteTask(id);
    refresh();
  }

  List<Task> getByProject(String projectId) {
    return state.where((t) => t.projectId == projectId).toList();
  }

  List<Task> getByStatus(TaskStatus status) {
    return state.where((t) => t.status == status).toList();
  }
}

// ============ Invoices ============
final invoicesProvider =
    StateNotifierProvider<InvoicesNotifier, List<Invoice>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return InvoicesNotifier(storage);
});

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  final StorageService _storage;
  InvoicesNotifier(this._storage) : super(_storage.getAllInvoices());

  void refresh() {
    state = _storage.getAllInvoices();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _storage.saveInvoice(invoice);
    refresh();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await _storage.saveInvoice(invoice);
    refresh();
  }

  Future<void> deleteInvoice(String id) async {
    await _storage.deleteInvoice(id);
    refresh();
  }

  List<Invoice> getByStatus(String status) {
    return state.where((i) => i.status == status).toList();
  }

  List<Invoice> getByClient(String clientId) {
    return state.where((i) => i.clientId == clientId).toList();
  }

  double get totalRevenue => state
      .where((i) => i.status == 'paid')
      .fold(0.0, (sum, i) => sum + i.total);

  double get outstanding =>
      state.where((i) => i.status != 'paid' && i.status != 'cancelled')
          .fold(0.0, (sum, i) => sum + i.balanceDue);

  double get overdue =>
      state.where((i) => i.isOverdue).fold(0.0, (sum, i) => sum + i.balanceDue);
}

// ============ Quotes ============
final quotesProvider =
    StateNotifierProvider<QuotesNotifier, List<Quote>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return QuotesNotifier(storage);
});

class QuotesNotifier extends StateNotifier<List<Quote>> {
  final StorageService _storage;
  QuotesNotifier(this._storage) : super(_storage.getAllQuotes());

  void refresh() {
    state = _storage.getAllQuotes();
  }

  Future<void> addQuote(Quote quote) async {
    await _storage.saveQuote(quote);
    refresh();
  }

  Future<void> updateQuote(Quote quote) async {
    await _storage.saveQuote(quote);
    refresh();
  }

  Future<void> deleteQuote(String id) async {
    await _storage.deleteQuote(id);
    refresh();
  }

  List<Quote> getByStatus(String status) {
    return state.where((q) => q.status == status).toList();
  }

  List<Quote> getByClient(String clientId) {
    return state.where((q) => q.clientId == clientId).toList();
  }

  List<Quote> getByLead(String leadId) {
    return state.where((q) => q.leadId == leadId).toList();
  }
}

// ============ Contracts ============
final contractsProvider =
    StateNotifierProvider<ContractsNotifier, List<Contract>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ContractsNotifier(storage);
});

class ContractsNotifier extends StateNotifier<List<Contract>> {
  final StorageService _storage;
  ContractsNotifier(this._storage) : super(_storage.getAllContracts());

  void refresh() {
    state = _storage.getAllContracts();
  }

  Future<void> addContract(Contract contract) async {
    await _storage.saveContract(contract);
    refresh();
  }

  Future<void> updateContract(Contract contract) async {
    await _storage.saveContract(contract);
    refresh();
  }

  Future<void> deleteContract(String id) async {
    await _storage.deleteContract(id);
    refresh();
  }

  List<Contract> getByClient(String clientId) {
    return state.where((c) => c.clientId == clientId).toList();
  }
}

// ============ Time Entries ============
final timeEntriesProvider =
    StateNotifierProvider<TimeEntriesNotifier, List<TimeEntry>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TimeEntriesNotifier(storage);
});

class TimeEntriesNotifier extends StateNotifier<List<TimeEntry>> {
  final StorageService _storage;
  TimeEntriesNotifier(this._storage) : super(_storage.getAllTimeEntries());

  void refresh() {
    state = _storage.getAllTimeEntries();
  }

  Future<void> addTimeEntry(TimeEntry entry) async {
    await _storage.saveTimeEntry(entry);
    refresh();
  }

  Future<void> updateTimeEntry(TimeEntry entry) async {
    await _storage.saveTimeEntry(entry);
    refresh();
  }

  Future<void> deleteTimeEntry(String id) async {
    await _storage.deleteTimeEntry(id);
    refresh();
  }

  List<TimeEntry> getByProject(String projectId) {
    return state.where((t) => t.projectId == projectId).toList();
  }

  double getTotalHoursForProject(String projectId) {
    return getByProject(projectId).fold(0.0, (sum, e) => sum + e.hours);
  }

  double getBillableHoursForProject(String projectId) {
    return getByProject(projectId)
        .where((e) => e.isBillable)
        .fold(0.0, (sum, e) => sum + e.hours);
  }
}

// ============ Documents ============
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, List<AppDocument>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DocumentsNotifier(storage);
});

class DocumentsNotifier extends StateNotifier<List<AppDocument>> {
  final StorageService _storage;
  DocumentsNotifier(this._storage) : super(_storage.getAllDocuments());

  void refresh() {
    state = _storage.getAllDocuments();
  }

  Future<void> addDocument(AppDocument doc) async {
    await _storage.saveDocument(doc);
    refresh();
  }

  Future<void> deleteDocument(String id) async {
    await _storage.deleteDocument(id);
    refresh();
  }

  List<AppDocument> getByProject(String projectId) {
    return state.where((d) => d.projectId == projectId).toList();
  }

  List<AppDocument> getByClient(String clientId) {
    return state.where((d) => d.clientId == clientId).toList();
  }
}

// ============ Communications ============
final communicationsProvider =
    StateNotifierProvider<CommunicationsNotifier, List<Communication>>(
        (ref) {
  final storage = ref.watch(storageServiceProvider);
  return CommunicationsNotifier(storage);
});

class CommunicationsNotifier extends StateNotifier<List<Communication>> {
  final StorageService _storage;
  CommunicationsNotifier(this._storage)
      : super(_storage.getAllCommunications());

  void refresh() {
    state = _storage.getAllCommunications();
  }

  Future<void> addCommunication(Communication comm) async {
    await _storage.saveCommunication(comm);
    refresh();
  }

  Future<void> deleteCommunication(String id) async {
    await _storage.deleteCommunication(id);
    refresh();
  }

  List<Communication> getByClient(String clientId) {
    return state.where((c) => c.clientId == clientId).toList();
  }

  List<Communication> getByLead(String leadId) {
    return state.where((c) => c.leadId == leadId).toList();
  }
}

// ============ Calendar Events ============
final eventsProvider =
    StateNotifierProvider<EventsNotifier, List<CalendarEvent>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return EventsNotifier(storage);
});

class EventsNotifier extends StateNotifier<List<CalendarEvent>> {
  final StorageService _storage;
  EventsNotifier(this._storage) : super(_storage.getAllEvents());

  void refresh() {
    state = _storage.getAllEvents();
  }

  Future<void> addEvent(CalendarEvent event) async {
    await _storage.saveEvent(event);
    refresh();
  }

  Future<void> updateEvent(CalendarEvent event) async {
    await _storage.saveEvent(event);
    refresh();
  }

  Future<void> deleteEvent(String id) async {
    await _storage.deleteEvent(id);
    refresh();
  }

  List<CalendarEvent> getByClient(String clientId) {
    return state.where((e) => e.clientId == clientId).toList();
  }

  List<CalendarEvent> getUpcoming() {
    final now = DateTime.now();
    return state.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}

// ============ Milestones ============
final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, List<Milestone>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return MilestonesNotifier(storage);
});

class MilestonesNotifier extends StateNotifier<List<Milestone>> {
  final StorageService _storage;
  MilestonesNotifier(this._storage) : super(_storage.getAllMilestones());

  void refresh() {
    state = _storage.getAllMilestones();
  }

  Future<void> addMilestone(Milestone milestone) async {
    await _storage.saveMilestone(milestone);
    refresh();
  }

  Future<void> updateMilestone(Milestone milestone) async {
    await _storage.saveMilestone(milestone);
    refresh();
  }

  Future<void> deleteMilestone(String id) async {
    await _storage.deleteMilestone(id);
    refresh();
  }

  List<Milestone> getByProject(String projectId) {
    return state.where((m) => m.projectId == projectId).toList();
  }
}
