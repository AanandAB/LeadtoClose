# LeadToClose

**Compliance-Aware Freelance Business Management — Built for Indian Freelance Developers**

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)](https://flutter.dev)

> One app that takes a freelance project from first conversation to closed-won and paid — where Indian legal and compliance intelligence is baked into a rules engine, so every quote, contract, and invoice is automatically correct for the specific project type.

---

## The Problem

As a freelance web/software developer in India, every project requires you to *manually*:

- Figure out what legal/compliance requirements apply (GST, DPDPA, CERT-In, Consumer Protection Rules, IP terms)
- Price the project, often forgetting to charge for compliance work (privacy flows, grievance officer blocks, etc.)
- Draft a contract from scratch, hoping you didn't forget a clause
- Track leads through negotiation manually (WhatsApp threads, memory)
- Generate GST/TDS-correct invoices
- Chase payment with no structured escalation path

**LeadToClose fixes all of this.**

---

## Features

### 🏗️ Pipeline & CRM
- **7-stage Kanban board** — New Lead → Qualified → Discovery Done → Quote Sent → Negotiating → Won → Lost
- Quick-add lead form with source tracking
- Lead detail with activity log, notes, stage management
- Analytics dashboard with pipeline breakdown

### 🔍 Discovery Questionnaire
- **11 guided dropdown questions** — 2-3 minutes, no free text required
- Classifies project type, data collection, payments, client location, hosting, IP ownership
- Feeds directly into the compliance rules engine

### ⚖️ Compliance Rules Engine (17 Rules)
- **Pure, testable function** — `ProjectProfile → ComplianceChecklist`
- Covers: DPDPA 2023, GDPR, CCPA, CERT-In, Consumer Protection E-Commerce Rules, Legal Metrology, GST inter-state/export, IP assignment
- Every rule maps a discovery answer to a compliance action
- Categorized: Build / Contract / Advisory / Invoicing
- Viewable in-app at `/rules-engine`

### 💰 Quote Generator
- Auto-assembles line items from project tier + compliance add-ons
- GST treatment: CGST+SGST / IGST / Zero-Rated (Export) / Not Registered
- Configurable rate card per project tier
- PDF export — professional branded quotes

### 📜 Contract Generator
- **13+ clause Service Agreement** auto-generated from project profile
- **Standard clauses:** Scope of Work, Payment Terms, Timeline, Revisions, Confidentiality, Termination, Indemnification, Electronic Execution (IT Act 2000)
- **Conditional clauses** triggered by discovery answers:
  - DPDPA Data Processor clause
  - CERT-In incident reporting + 180-day logging
  - E-commerce content responsibility
  - IP Assignment vs License
  - Indian jurisdiction for export clients
- Non-removable legal disclaimer on every contract
- PDF export — proper legal formatting

### 🧠 IP Assessment
- Standalone 3-question wizard
- Recommends Assignment vs License based on reuse and resale plans
- Pricing premium calculator (30-50% for full IP transfer)
- Client-facing plain-language explainer

### 🧾 Invoice Generator
- **GST/TDS-aware** — auto-calculates CGST/SGST, IGST, zero-rated export
- Expected TDS deduction shown (10% u/s 194J) — never surprised by lower bank credit
- SAC codes auto-mapped (998314 for IT services)
- Sequential invoice numbering (statutory requirement)
- Multi-currency support (USD for foreign clients)
- PDF export — PAN, GSTIN, SAC code, bank details, CA-ready

### 💸 Payment Recovery
- **Interactive 6-step escalation ladder** with a day-overdue slider:
  1. **Day 1+** — Friendly reminder
  2. **Day 15+** — Firm reminder + late fee recalculation
  3. **Day 30+** — Legal notice summary
  4. **Day 45+** — MSME Samadhaan complaint (if Udyam registered)
  5. **Day 60+** — District Consumer Commission
  6. **Day 90+** — Civil suit reference pack
- **Limitation period countdown** — 3-year tracker (Limitation Act, 1963)

### 📊 Tax & Compliance Calendar
- **44ADA recommender** — presumptive vs ITR-3, flags ₹50L/₹75L threshold breach
- Advance tax schedule — 4 quarterly instalments with estimated liability
- GST filing calendar — GSTR-1, GSTR-3B, LUT renewal
- DTAA / Form 67 foreign tax credit tracker
- Year-end income summary — hand directly to CA

### 📈 Turnover Tracker
- Real-time ₹20L GST threshold gauge
- Inter-state client flag — registration mandatory regardless of turnover
- What-happens-when-you-cross explainer

---

## Architecture

```
LeadToClose/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # MaterialApp.router with dark theme
│   ├── providers.dart                     # Riverpod providers
│   ├── core/
│   │   ├── theme.dart                     # AppColors, AppTypography, AppTheme
│   │   └── router.dart                    # GoRouter with 14 routes
│   ├── models/
│   │   ├── business_profile.dart          # Freelancer's own data
│   │   ├── lead.dart                      # Lead with notes, profile ref
│   │   ├── project_profile.dart           # 11 discovery answers
│   │   ├── compliance_item.dart           # Checklist items
│   │   ├── quote.dart                     # Quote with line items
│   │   ├── contract.dart                  # Contract with clauses
│   │   └── invoice.dart                   # Invoice with GST/TDS
│   ├── services/
│   │   ├── storage_service.dart           # Hive persistence
│   │   ├── rules_engine.dart              # Pure function: profile → checklist
│   │   ├── quote_service.dart             # Quote generation
│   │   ├── contract_service.dart          # Contract assembly + PDF
│   │   ├── invoice_service.dart           # Invoice generation + PDF
│   │   └── pdf_service.dart               # Quote PDF export
│   └── features/
│       ├── onboarding/                    # Business profile setup
│       ├── dashboard/                     # Pipeline + Leads + Analytics
│       ├── pipeline/                      # Lead form, lead detail
│       ├── discovery/                     # 11-question questionnaire
│       ├── compliance/                    # Checklist screen
│       ├── quotes/                        # Quote, contract, IP assessment
│       ├── invoices/                      # Invoice screen
│       ├── payments/                      # Payment recovery
│       ├── tax/                           # Tax calendar, turnover tracker
│       ├── rules/                         # Rules engine viewer
│       └── settings/                      # Settings screen
```

### Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24 / Dart 3.5 |
| State | Riverpod 2.x |
| Navigation | GoRouter 14.x |
| Storage | Hive (local, no backend required) |
| PDF | `pdf` + `printing` packages |
| Theme | Custom dark glassmorphism design system |

### Design Decisions

- **Rules engine is a pure function** — `ProjectProfile → ComplianceChecklist`. Zero UI dependencies, independently unit-testable.
- **Contract clauses and compliance checklist share the same triggers** — single source of truth prevents drift.
- **Config-driven rate card and rules** — update a JSON or in-app config when GST thresholds or DPDPA dates change, not code.
- **All data stays local** — Hive stores everything on-device. No cloud dependency for a single-user app.
- **Declarative conditional content** — every clause, line item, and advisory is tagged with the discovery answer that triggered it.

---

## Getting Started

### Prerequisites

- Flutter SDK 3.24 or later
- Windows (primary target), Android, iOS, or Web

### Installation

```bash
# Clone the repository
git clone https://github.com/AanandAB/LeadtoClose.git
cd LeadtoClose

# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Build release
flutter build windows --release
```

### First Run

1. Launch the app — you'll land on the **Business Profile** setup screen
2. Fill in your PAN, GSTIN (if registered), Udyam number (if registered), home state, and banking details
3. Click **Save & Continue** — you're on the dashboard
4. Click **New Lead** to create your first lead
5. Open the lead → **Discovery** to run the questionnaire
6. View the **Compliance Checklist** → **Generate Quote** → **Contract** → **Invoice**

---

## Compliance Coverage

| Regulation | Coverage |
|------------|----------|
| **DPDPA 2023** | Consent flow, privacy notice, data fiduciary/processor clauses, children's data provisions |
| **GDPR** | Cookie consent, data portability, right to erasure (for EU-audience projects) |
| **CCPA** | Privacy disclosures, opt-out mechanism (for US/California-audience projects) |
| **CERT-In** | 6-hour incident reporting, 180-day logging, data processor SLA |
| **Consumer Protection (E-Commerce) Rules 2020** | Grievance Officer block, return/refund/shipping policies |
| **Legal Metrology** | MRP, net quantity, manufacturer, origin, expiry display fields |
| **GST** | CGST/SGST/IGST/Zero-rated calculation, inter-state mandatory flag, LUT renewal |
| **IT Act 2000** | Electronic execution clause (Section 10-A) |
| **MSME Act** | Samadhaan complaint access, 45-day payment rule |
| **Limitation Act 1963** | 3-year recovery suit countdown |
| **Income Tax** | Section 44ADA presumptive, 194J TDS, advance tax, DTAA/Form 67 |

---

## Roadmap

- [x] **Phase 1** — Pipeline, Discovery, Compliance Engine, Quotes
- [x] **Phase 2** — Contract Generator, IP Assessment
- [x] **Phase 3** — GST/TDS Invoices, Payment Recovery, Tax Calendar
- [x] **Phase 4** — Turnover Tracker, Rules Engine Viewer
- [ ] E-signature integration (DocuSign/Zoho Sign)
- [ ] Payment gateway for invoice links (Razorpay/Cashfree)
- [ ] Recurring invoices for retainer clients
- [ ] Mobile-responsive layout for phone use
- [ ] Rules engine in-app editor
- [ ] Data export/import for CA handoff

---

## Contributing

This is an open source project aimed at helping Indian freelance developers navigate compliance. Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Areas That Need Help

- **Testing** — unit tests for the rules engine and services
- **Mobile layout** — responsive design for phone screens
- **Rule updates** — keeping the rules engine current with evolving Indian law
- **Localization** — Indian language support
- **Documentation** — user guides, video walkthroughs

---

## Disclaimer

**LeadToClose provides compliance checklists and draft documents based on stated project parameters. It is NOT a substitute for review by a qualified lawyer.** Generated contracts and compliance recommendations should be reviewed before use, especially for enterprise-tier or first-of-kind engagements. Indian compliance law (DPDPA rules, CERT-In penalties, GST thresholds) is actively evolving — the rules engine reflects the state of law as of mid-2026.

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

Built with Flutter by [Aanand AB](https://github.com/AanandAB)
