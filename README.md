# Naro

**Modern CRM for Freelance Developers — From Lead to Invoice**

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)](https://flutter.dev)

> A premium, full-featured CRM built for freelance web/software developers — covering the entire client lifecycle from first contact to payment.

---

## Features

### Pipeline & CRM
- **7-stage Kanban board** — New Lead → Contacted → Qualified → Proposal Sent → Negotiation → Won → Lost
- Quick-add lead form with source tracking
- Lead scoring (hot/warm/cold) based on engagement
- Lead → Client conversion in one click

### Client Management
- Company + multiple contacts per client
- 360° client view: projects, invoices, proposals, messages in one timeline
- Client health scoring (active, at-risk, dormant)
- Search and filter by health status

### Proposals & Quotes
- Line-item pricing (fixed price, hourly, milestone-based)
- Status tracking: Draft → Sent → Accepted/Rejected
- Win rate analytics
- Convert accepted proposals → contracts + projects

### Contracts
- Template types: SOW, MSA, NDA, Retainer
- Status tracking: Draft → Sent → Active → Expired
- Auto-fill from client & proposal data

### Project Management
- Kanban + List views
- Task management with status tracking (To Do → In Progress → Review → Done)
- Budget vs actual tracking
- Priority levels and due dates

### Time Tracking
- Real-time stopwatch timer (start/stop/reset)
- Manual time entry
- Weekly stats and billable hours tracking
- Link time entries to projects

### Invoicing & Payments
- Status filters: Draft → Sent → Paid → Overdue
- Auto payment reminders
- Multi-currency support
- Payment status dashboard

### Communication Hub
- Email, call, meeting, and note logging
- Internal vs client-visible messages
- Unified inbox filtered by type

### Calendar & Scheduling
- Month view with event indicators
- Day detail panel
- Meeting, deadline, and call event types

### Documents & Files
- Grid and list view modes
- File type icons and color coding
- Upload and version tracking

### Reports & Analytics
- Revenue dashboard (paid, outstanding, overdue)
- Pipeline conversion funnel
- Project and client overview

### Settings & Customization
- Business profile setup (name, logo, currency)
- Light/Dark theme toggle
- Payment terms and invoice settings
- Integration toggles

### Onboarding Wizard
- 3-step setup: Business Info → Preferences → Done
- Quick start for new users

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24 / Dart 3.5 |
| State | Riverpod 2.x |
| Navigation | GoRouter 14.x |
| Storage | Hive (local, no backend required) |
| Theme | Premium light/dark with custom palette |

---

## Getting Started

### Build from Source

```bash
git clone https://github.com/AanandAB/LeadtoClose.git
cd LeadtoClose
flutter pub get
flutter run -d windows
```

### First Run

1. Launch — you'll land on the **Onboarding Wizard**
2. Enter your business name and preferences
3. You're in! The **Dashboard** shows your pipeline at a glance
4. Add your first lead in **Pipeline**
5. Move leads through stages, create proposals, sign contracts
6. Track time, generate invoices, get paid

---

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp.router with theme
├── providers.dart               # Riverpod providers for all entities
├── core/
│   ├── theme.dart               # Light/dark color palette
│   └── router.dart              # GoRouter with 18+ routes
├── models/
│   ├── lead.dart                # Lead with pipeline stages
│   ├── client.dart              # Client + contacts
│   ├── project.dart             # Project + milestones
│   ├── task.dart                # Task management
│   ├── quote.dart               # Proposals/quotes
│   ├── contract.dart            # Contracts
│   ├── invoice.dart             # Invoicing
│   ├── time_entry.dart          # Time tracking
│   ├── communication.dart       # Messages
│   ├── event.dart               # Calendar events
│   ├── document.dart            # File management
│   └── app_settings.dart        # Settings & preferences
├── services/
│   └── storage_service.dart     # Hive persistence
├── widgets/
│   ├── sidebar.dart             # Navigation sidebar
│   └── shared_widgets.dart      # Reusable components
└── features/
    ├── onboarding/              # Setup wizard
    ├── shell/                   # Main app shell
    ├── dashboard/               # Overview & stats
    ├── pipeline/                # Kanban CRM
    ├── clients/                 # Client management
    ├── proposals/               # Quotes & proposals
    ├── contracts/               # Contract management
    ├── projects/                # Project & task management
    ├── time_tracking/           # Timer & time entries
    ├── invoices/                # Invoicing
    ├── communication/           # Messages hub
    ├── calendar/                # Scheduling
    ├── documents/               # File vault
    ├── reports/                 # Analytics
    └── settings/                # Configuration
```

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

Built with Flutter by [Aanand AB](https://github.com/AanandAB)
