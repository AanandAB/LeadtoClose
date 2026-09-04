import 'package:hive_flutter/hive_flutter.dart';
import '../models/lead.dart';
import '../models/client.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/invoice.dart';
import '../models/quote.dart';
import '../models/contract.dart';
import '../models/time_entry.dart';
import '../models/document.dart';
import '../models/communication.dart';
import '../models/event.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _settingsKey = 'app_settings';
  static const String _settingsBox = 'settings';
  static const String _leadsBox = 'leads';
  static const String _clientsBox = 'clients';
  static const String _projectsBox = 'projects';
  static const String _tasksBox = 'tasks';
  static const String _invoicesBox = 'invoices';
  static const String _quotesBox = 'quotes';
  static const String _contractsBox = 'contracts';
  static const String _timeEntriesBox = 'time_entries';
  static const String _documentsBox = 'documents';
  static const String _communicationsBox = 'communications';
  static const String _eventsBox = 'events';
  static const String _milestonesBox = 'milestones';

  late Box _settings;
  late Box _leads;
  late Box _clients;
  late Box _projects;
  late Box _tasks;
  late Box _invoices;
  late Box _quotes;
  late Box _contracts;
  late Box _timeEntries;
  late Box _documents;
  late Box _communications;
  late Box _events;
  late Box _milestones;

  Future<void> init() async {
    await Hive.initFlutter();
    _settings = await Hive.openBox(_settingsBox);
    _leads = await Hive.openBox(_leadsBox);
    _clients = await Hive.openBox(_clientsBox);
    _projects = await Hive.openBox(_projectsBox);
    _tasks = await Hive.openBox(_tasksBox);
    _invoices = await Hive.openBox(_invoicesBox);
    _quotes = await Hive.openBox(_quotesBox);
    _contracts = await Hive.openBox(_contractsBox);
    _timeEntries = await Hive.openBox(_timeEntriesBox);
    _documents = await Hive.openBox(_documentsBox);
    _communications = await Hive.openBox(_communicationsBox);
    _events = await Hive.openBox(_eventsBox);
    _milestones = await Hive.openBox(_milestonesBox);
  }

  // ============ Settings ============
  AppSettings getSettings() {
    final data = _settings.get(_settingsKey);
    if (data == null) return AppSettings();
    return AppSettings.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.put(_settingsKey, settings.toJson());
  }

  bool get hasSettings => _settings.containsKey(_settingsKey);
  bool get isSetupComplete {
    if (!hasSettings) return false;
    final s = getSettings();
    return s.isComplete;
  }

  // ============ Leads ============
  List<Lead> getAllLeads() {
    return _leads.values
        .map((v) => Lead.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Lead? getLead(String id) {
    final data = _leads.get(id);
    if (data == null) return null;
    return Lead.fromJson(Map<String, dynamic>.from(data));
  }

  List<Lead> getLeadsByStage(LeadStage stage) {
    return getAllLeads().where((l) => l.stage == stage).toList();
  }

  Future<void> saveLead(Lead lead) async {
    await _leads.put(lead.id, lead.toJson());
  }

  Future<void> deleteLead(String id) async {
    await _leads.delete(id);
  }

  // ============ Clients ============
  List<Client> getAllClients() {
    return _clients.values
        .map((v) => Client.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Client? getClient(String id) {
    final data = _clients.get(id);
    if (data == null) return null;
    return Client.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> saveClient(Client client) async {
    await _clients.put(client.id, client.toJson());
  }

  Future<void> deleteClient(String id) async {
    await _clients.delete(id);
  }

  // ============ Projects ============
  List<Project> getAllProjects() {
    return _projects.values
        .map((v) => Project.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Project? getProject(String id) {
    final data = _projects.get(id);
    if (data == null) return null;
    return Project.fromJson(Map<String, dynamic>.from(data));
  }

  List<Project> getProjectsByClient(String clientId) {
    return getAllProjects().where((p) => p.clientId == clientId).toList();
  }

  List<Project> getProjectsByStatus(ProjectStatus status) {
    return getAllProjects().where((p) => p.status == status).toList();
  }

  Future<void> saveProject(Project project) async {
    await _projects.put(project.id, project.toJson());
  }

  Future<void> deleteProject(String id) async {
    await _projects.delete(id);
  }

  // ============ Tasks ============
  List<Task> getAllTasks() {
    return _tasks.values
        .map((v) => Task.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<Task> getTasksByProject(String projectId) {
    return getAllTasks().where((t) => t.projectId == projectId).toList();
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return getAllTasks().where((t) => t.status == status).toList();
  }

  Task? getTask(String id) {
    final data = _tasks.get(id);
    if (data == null) return null;
    return Task.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> saveTask(Task task) async {
    await _tasks.put(task.id, task.toJson());
  }

  Future<void> deleteTask(String id) async {
    await _tasks.delete(id);
  }

  // ============ Invoices ============
  List<Invoice> getAllInvoices() {
    return _invoices.values
        .map((v) => Invoice.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Invoice? getInvoice(String id) {
    final data = _invoices.get(id);
    if (data == null) return null;
    return Invoice.fromJson(Map<String, dynamic>.from(data));
  }

  List<Invoice> getInvoicesByClient(String clientId) {
    return getAllInvoices().where((i) => i.clientId == clientId).toList();
  }

  List<Invoice> getInvoicesByStatus(String status) {
    return getAllInvoices().where((i) => i.status == status).toList();
  }

  Future<void> saveInvoice(Invoice invoice) async {
    await _invoices.put(invoice.id, invoice.toJson());
  }

  Future<void> deleteInvoice(String id) async {
    await _invoices.delete(id);
  }

  // ============ Quotes ============
  List<Quote> getAllQuotes() {
    return _quotes.values
        .map((v) => Quote.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Quote? getQuote(String id) {
    final data = _quotes.get(id);
    if (data == null) return null;
    return Quote.fromJson(Map<String, dynamic>.from(data));
  }

  List<Quote> getQuotesByClient(String clientId) {
    return getAllQuotes().where((q) => q.clientId == clientId).toList();
  }

  List<Quote> getQuotesByLead(String leadId) {
    return getAllQuotes().where((q) => q.leadId == leadId).toList();
  }

  Future<void> saveQuote(Quote quote) async {
    await _quotes.put(quote.id, quote.toJson());
  }

  Future<void> deleteQuote(String id) async {
    await _quotes.delete(id);
  }

  // ============ Contracts ============
  List<Contract> getAllContracts() {
    return _contracts.values
        .map((v) => Contract.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Contract? getContract(String id) {
    final data = _contracts.get(id);
    if (data == null) return null;
    return Contract.fromJson(Map<String, dynamic>.from(data));
  }

  List<Contract> getContractsByClient(String clientId) {
    return getAllContracts().where((c) => c.clientId == clientId).toList();
  }

  Future<void> saveContract(Contract contract) async {
    await _contracts.put(contract.id, contract.toJson());
  }

  Future<void> deleteContract(String id) async {
    await _contracts.delete(id);
  }

  // ============ Time Entries ============
  List<TimeEntry> getAllTimeEntries() {
    return _timeEntries.values
        .map((v) => TimeEntry.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TimeEntry> getTimeEntriesByProject(String projectId) {
    return getAllTimeEntries().where((t) => t.projectId == projectId).toList();
  }

  List<TimeEntry> getTimeEntriesByDateRange(DateTime start, DateTime end) {
    return getAllTimeEntries().where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalHoursByProject(String projectId) {
    return getTimeEntriesByProject(projectId)
        .fold(0.0, (sum, e) => sum + e.hours);
  }

  double getBillableHoursByProject(String projectId) {
    return getTimeEntriesByProject(projectId)
        .where((e) => e.isBillable)
        .fold(0.0, (sum, e) => sum + e.hours);
  }

  Future<void> saveTimeEntry(TimeEntry entry) async {
    await _timeEntries.put(entry.id, entry.toJson());
  }

  Future<void> deleteTimeEntry(String id) async {
    await _timeEntries.delete(id);
  }

  // ============ Documents ============
  List<AppDocument> getAllDocuments() {
    return _documents.values
        .map((v) => AppDocument.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<AppDocument> getDocumentsByProject(String projectId) {
    return getAllDocuments()
        .where((d) => d.projectId == projectId)
        .toList();
  }

  List<AppDocument> getDocumentsByClient(String clientId) {
    return getAllDocuments()
        .where((d) => d.clientId == clientId)
        .toList();
  }

  Future<void> saveDocument(AppDocument doc) async {
    await _documents.put(doc.id, doc.toJson());
  }

  Future<void> deleteDocument(String id) async {
    await _documents.delete(id);
  }

  // ============ Communications ============
  List<Communication> getAllCommunications() {
    return _communications.values
        .map((v) => Communication.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Communication> getCommunicationsByClient(String clientId) {
    return getAllCommunications()
        .where((c) => c.clientId == clientId)
        .toList();
  }

  List<Communication> getCommunicationsByLead(String leadId) {
    return getAllCommunications()
        .where((c) => c.leadId == leadId)
        .toList();
  }

  Future<void> saveCommunication(Communication comm) async {
    await _communications.put(comm.id, comm.toJson());
  }

  Future<void> deleteCommunication(String id) async {
    await _communications.delete(id);
  }

  // ============ Calendar Events ============
  List<CalendarEvent> getAllEvents() {
    return _events.values
        .map((v) => CalendarEvent.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<CalendarEvent> getEventsByDateRange(DateTime start, DateTime end) {
    return getAllEvents().where((e) {
      return e.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
          e.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<CalendarEvent> getEventsByClient(String clientId) {
    return getAllEvents().where((e) => e.clientId == clientId).toList();
  }

  Future<void> saveEvent(CalendarEvent event) async {
    await _events.put(event.id, event.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await _events.delete(id);
  }

  // ============ Milestones ============
  List<Milestone> getAllMilestones() {
    return _milestones.values
        .map((v) => Milestone.fromJson(Map<String, dynamic>.from(v)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<Milestone> getMilestonesByProject(String projectId) {
    return getAllMilestones()
        .where((m) => m.projectId == projectId)
        .toList();
  }

  Future<void> saveMilestone(Milestone milestone) async {
    await _milestones.put(milestone.id, milestone.toJson());
  }

  Future<void> deleteMilestone(String id) async {
    await _milestones.delete(id);
  }

  // ============ Analytics Helpers ============
  double getTotalRevenue() {
    return getAllInvoices()
        .where((i) => i.status == 'paid')
        .fold(0.0, (sum, i) => sum + i.total);
  }

  double getOutstandingAmount() {
    return getAllInvoices()
        .where((i) => i.status != 'paid' && i.status != 'cancelled')
        .fold(0.0, (sum, i) => sum + i.balanceDue);
  }

  double getOverdueAmount() {
    return getAllInvoices()
        .where((i) => i.isOverdue)
        .fold(0.0, (sum, i) => sum + i.balanceDue);
  }

  int getActiveProjectCount() {
    return getAllProjects()
        .where((p) => p.status == ProjectStatus.active)
        .length;
  }

  int getPendingInvoiceCount() {
    return getAllInvoices()
        .where((i) => i.status != 'paid' && i.status != 'cancelled')
        .length;
  }

  int getOpenLeadCount() {
    return getAllLeads().where((l) =>
        l.stage != LeadStage.won && l.stage != LeadStage.lost)
        .length;
  }
}
