import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../dashboard/dashboard_screen.dart';
import '../pipeline/pipeline_screen.dart';
import '../clients/clients_screen.dart';
import '../proposals/proposals_screen.dart';
import '../contracts/contracts_screen.dart';
import '../projects/projects_screen.dart';
import '../time_tracking/time_tracking_screen.dart';
import '../invoices/invoices_screen.dart';
import '../communication/communication_hub_screen.dart';
import '../calendar/calendar_screen.dart';
import '../documents/documents_screen.dart';
import '../reports/reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentTab: _currentTab,
            onTabChanged: (tab) => setState(() => _currentTab = tab),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentTab) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const PipelineScreen();
      case 2:
        return const ClientsScreen();
      case 3:
        return const ProposalsScreen();
      case 4:
        return const ContractsScreen();
      case 5:
        return const ProjectsScreen();
      case 6:
        return const TimeTrackingScreen();
      case 7:
        return const InvoicesScreen();
      case 8:
        return const CommunicationHubScreen();
      case 9:
        return const CalendarScreen();
      case 10:
        return const DocumentsScreen();
      case 11:
        return const ReportsScreen();
      default:
        return const DashboardScreen();
    }
  }
}
