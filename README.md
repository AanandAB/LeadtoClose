# LeadToClose

**Compliance-Aware Freelance Business Management — Built for Indian Freelance Developers**

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)](https://flutter.dev)
[![Version](https://img.shields.io/badge/version-1.1.0-blue)](https://github.com/AanandAB/LeadtoClose/releases)

> One app that takes a freelance project from first conversation to closed-won and paid — where Indian legal and compliance intelligence is baked into a rules engine, so every quote, contract, invoice, and client message is automatically correct for the specific project type.

---

## The Problem

As a freelance web/software developer in India, every project requires you to *manually*:

- Figure out what legal/compliance requirements apply (GST, DPDPA, CERT-In, Consumer Protection Rules, IP terms)
- Price the project, often forgetting to charge for compliance work (privacy flows, grievance officer blocks, etc.)
- Draft a contract from scratch, hoping you didn't forget a clause
- Track leads through negotiation manually (WhatsApp threads, memory)
- Generate GST/TDS-correct invoices
- Write client emails and WhatsApp messages at every stage
- Chase payment with no structured escalation path

**LeadToClose fixes all of this.**

---

## Features

### Pipeline & CRM
- **7-stage Kanban board** — New Lead → Qualified → Discovery Done → Quote Sent → Negotiating → Won → Lost
- Quick-add lead form with source tracking
- Lead detail with activity log, notes, stage management
- Analytics dashboard with pipeline breakdown

### Discovery Questionnaire (26 Questions, 7 Sections)
- **Guided section-based wizard** with progress indicators
- **7 themed sections:** Project Type & Scope, Client Details, Data & Privacy, Commerce & Payments, Hosting & Maintenance, IP & Assets, Legal & Contract
- Multi-select for features, data types, and target audience
- **Help text on every question** explaining *why* it matters legally
- Based on comprehensive Indian freelance legal research — `freelance-legal-guide-india.md` and `website-handover-legal-compliance-india.md`

### Compliance Rules Engine (35+ Rules)
- **Pure, testable function** — `ProjectProfile → ComplianceChecklist`
- Covers: DPDPA 2023, GDPR, CCPA, CERT-In, Consumer Protection E-Commerce Rules, Legal Metrology, GST, Copyright Act, IT Act, MSME Act, SPDI Rules, Limitation Act
- Every rule maps a discovery answer to a compliance action
- Categorized: Build / Contract / Advisory / Invoicing
- Viewable in-app at `/rules-engine` — 35+ expandable rule cards with triggers and contract clause previews

### Quote Generator
- Auto-assembles line items from project tier + compliance add-ons
- GST treatment: CGST+SGST / IGST / Zero-Rated (Export) / Not Registered
- Configurable rate card per project tier (Basic ₹15K through Enterprise ₹3.5L)
- Compliance line items auto-priced (DPDPA, E-commerce, CERT-In, IP premium)
- PDF export — professional branded quotes

### Contract Generator
- **13+ clause Service Agreement** auto-generated from project profile
- **Standard clauses:** Scope of Work, Payment Terms, Timeline, Revisions, Confidentiality, Termination, Indemnification, Electronic Execution (IT Act Section 10-A)
- **Conditional clauses** triggered by discovery answers:
  - DPDPA Data Processor clause
  - CERT-In incident reporting + 180-day logging
  - E-commerce content responsibility
  - IP Assignment vs License
  - Indian jurisdiction for export clients
  - Data export + transition on termination (for SaaS)
- Non-removable legal disclaimer on every contract
- PDF export — proper legal formatting

### IP Assessment
- Standalone 3-question wizard
- Recommends Assignment vs License based on reuse and resale plans
- Pricing premium calculator (30-50% for full IP transfer)
- Client-facing plain-language explainer — ready to share

### Invoice Generator
- **GST/TDS-aware** — auto-calculates CGST/SGST, IGST, zero-rated export
- Expected TDS deduction shown (10% u/s 194J) — never surprised by lower bank credit
- SAC codes auto-mapped (998314 IT consulting, 998364 web design)
- Sequential invoice numbering (statutory requirement)
- Multi-currency support (USD for foreign clients)
- PDF export — PAN, GSTIN, SAC code, bank details, CA-ready

### Payment Recovery
- **Interactive 6-step escalation ladder** with a day-overdue slider:
  1. **Day 1+** — Friendly reminder
  2. **Day 15+** — Firm reminder + late fee recalculation
  3. **Day 30+** — Legal notice summary (ready for lawyer)
  4. **Day 45+** — MSME Samadhaan complaint (if Udyam registered)
  5. **Day 60+** — District Consumer Commission
  6. **Day 90+** — Civil suit reference pack
- **Limitation period countdown** — 3-year tracker (Limitation Act, 1963)
- **Udyam toggle** that gates MSME Samadhaan access

### Communication Generator (NEW in v1.1)
- **12 message templates** for every pipeline stage — New Lead through Payment Received
- **Both Email and WhatsApp** formats for each template
- **Email:** Full subject line + body with lead name, project type, quote totals, GST treatment, bank details
- **WhatsApp:** Concise, friendly short format — one-tap copy
- **Filter tabs:** All / Email / WhatsApp / Payment
- **Personalized** with live data: business name, owner name, phone, late fee %, quote amounts
- Covers: Introduction, Qualified follow-up, Discovery summary, Quote sent, Negotiation, Won onboarding, Lost graceful exit, Contract review, Invoice sent, Payment overdue (friendly + firm), Payment received

### Tax & Compliance Calendar
- **44ADA recommender** — presumptive vs ITR-3, flags ₹50L/₹75L threshold breach, reminds about foreign asset disclosure (Schedule FA)
- Advance tax schedule — 4 quarterly instalments with estimated liability
- GST filing calendar — GSTR-1 (11th), GSTR-3B (20th), LUT annual renewal with "expired LUT = 18% IGST" warning
- DTAA / Form 67 foreign tax credit tracker
- Year-end income summary — hand directly to CA

### Turnover Tracker
- ₹20L GST threshold gauge with percentage progress
- **Inter-state client flag** — registration mandatory regardless of turnover
- PAN-level aggregate reminder
- What-happens-when-you-cross explainer

### Business Profile
- All 28 Indian states + 8 union territories in dropdown
- PAN, GSTIN, Udyam registration fields
- Business structure picker (Sole Proprietor / OPC / LLP)
- Late fee percentage (feeds into contract and overdue notices)
- Bank details for invoice generation

---

## Architecture

```
LeadToClose/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # MaterialApp.router
│   ├── providers.dart                     # Riverpod providers
│   ├── core/
│   │   ├── theme.dart                     # Clean dark theme
│   │   └── router.dart                    # GoRouter with 15 routes
│   ├── models/
│   │   ├── business_profile.dart          # 36 states, PAN, GSTIN, Udyam
│   │   ├── lead.dart                      # Lead with notes, profile ref
│   │   ├── project_profile.dart           # 27 discovery fields
│   │   ├── compliance_item.dart           # Checklist items
│   │   ├── quote.dart                     # Quote with line items
│   │   ├── contract.dart                  # Contract with clauses
│   │   └── invoice.dart                   # GST/TDS invoice
│   ├── services/
│   │   ├── storage_service.dart           # Hive persistence
│   │   ├── rules_engine.dart              # 35+ rules: profile → checklist
│   │   ├── quote_service.dart             # Quote generation
│   │   ├── contract_service.dart          # Contract assembly + PDF
│   │   ├── invoice_service.dart           # Invoice generation + PDF
│   │   ├── communication_service.dart     # 12 email + WhatsApp templates
│   │   └── pdf_service.dart               # Quote PDF export
│   └── features/
│       ├── onboarding/                    # Business profile setup
│       ├── dashboard/                     # Pipeline + Leads + Analytics
│       ├── pipeline/                      # Lead form, lead detail
│       ├── discovery/                     # 26-question, 7-section wizard
│       ├── compliance/                    # Checklist screen
│       ├── quotes/                        # Quote, contract, IP assessment
│       ├── invoices/                      # Invoice screen
│       ├── payments/                      # Payment recovery
│       ├── communication/                 # Message templates ← NEW
│       ├── tax/                           # Tax calendar, turnover tracker
│       ├── rules/                         # Rules engine viewer
│       └── settings/                      # Settings screen
```

### Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24 / Dart 3.5 |
| State | Riverpod 2.x |
| Navigation | GoRouter 14.x (15 routes) |
| Storage | Hive (local, no backend required) |
| PDF | `pdf` + `printing` packages |
| Theme | Clean dark theme, single blue accent |

### Design Decisions

- **Rules engine is a pure function** — `ProjectProfile → ComplianceChecklist`. Zero UI dependencies, independently unit-testable.
- **Contract clauses and compliance checklist share the same triggers** — single source of truth prevents drift.
- **Config-driven rate card and rules** — update in-app when GST thresholds or DPDPA dates change, not code.
- **All data stays local** — Hive stores everything on-device. No cloud dependency for a single-user app.
- **Declarative conditional content** — every clause, line item, advisory, and message template is tagged with the discovery answer that triggered it.

---

## Getting Started

### Prerequisites

- Flutter SDK 3.24 or later
- Windows (primary target), Android, iOS, or Web

### Installation

```bash
git clone https://github.com/AanandAB/LeadtoClose.git
cd LeadtoClose
flutter pub get
flutter run -d windows

# Build release
flutter build windows --release
```

### First Run

1. Launch — you'll land on **Business Profile** setup
2. Fill in PAN, GSTIN, Udyam number, home state (all 36 Indian states/UTs), banking details
3. Save → Dashboard
4. **New Lead** → enter client details
5. Open lead → **Discovery** → answer 26 questions across 7 themed sections
6. View **Compliance Checklist** → **Generate Quote** → **Contract** → **Invoice**
7. Use **Messages** at any stage for ready-to-send email + WhatsApp templates
8. Track payments with the **Payment Recovery** escalation ladder

---

## Compliance Coverage

| Regulation | Coverage |
|------------|----------|
| **DPDPA 2023** | Consent flow (Section 6), privacy notice (Section 5), data fiduciary/processor roles (Section 8), children's data (Section 9), regional language (Section 6(3)), startup exemption (Section 17(3)), breach notification (72 hours), penalties (up to ₹250 crore) |
| **GDPR** | Cookie consent, data portability, right to erasure (for EU-audience projects) |
| **CCPA** | Privacy disclosures, opt-out mechanism (for US/California-audience projects) |
| **CERT-In** | 6-hour incident reporting, 180-day logging, NTP synchronization, incident response documentation |
| **Consumer Protection (E-Commerce) Rules 2020** | Grievance Officer (48h ack, 30d resolve), return/refund/shipping policies, pre-ticked checkbox prohibition, COD classification |
| **Legal Metrology** | MRP, net quantity, manufacturer, country of origin, expiry display fields |
| **Copyright Act 1957** | Default ownership (Section 17), assignment requirements (Section 19), 5-year/India-only defaults |
| **GST** | CGST/SGST/IGST/Zero-rated, inter-state mandatory flag, LUT annual renewal, reverse charge on SaaS imports, PAN-level aggregate |
| **IT Act 2000** | Electronic execution (Section 10-A), cybercrime penalties, SPDI Rules 2011 |
| **MSME Act** | Samadhaan complaint access, 45-day payment rule, 3x RBI interest |
| **FEMA** | FIRA/FIRC tracking, proper banking channels, 6-year record retention |
| **Income Tax Act 2025** | Section 44ADA presumptive, 194J TDS, advance tax schedule, DTAA/Form 67, Schedule FA (foreign assets), ITR-3 vs ITR-4 guidance |
| **Limitation Act 1963** | 3-year recovery suit countdown |

---

## Roadmap

- [x] **v1.0** — Pipeline, Discovery, Compliance Engine, Quotes, Contracts, Invoices, Payment Recovery, Tax Calendar
- [x] **v1.1** — Expanded 26-question discovery (7 sections), 35+ rule engine, Communication Generator (12 email + WhatsApp templates), all 36 Indian states/UTs
- [ ] E-signature integration (DocuSign/Zoho Sign)
- [ ] Payment gateway for invoice links (Razorpay/Cashfree)
- [ ] Recurring invoices for retainer clients
- [ ] Mobile-responsive layout for phone use
- [ ] Rules engine in-app editor
- [ ] Data export/import for CA handoff
- [ ] Unit tests for rules engine and services

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
- **Rule updates** — keeping the rules engine current with evolving Indian law (DPDPA rules, CERT-In penalties, GST thresholds are all actively evolving through 2026-2027)
- **Localization** — Indian language support (22 scheduled languages)
- **Documentation** — user guides, video walkthroughs

---

## Disclaimer

**LeadToClose provides compliance checklists and draft documents based on stated project parameters. It is NOT a substitute for review by a qualified lawyer.** Generated contracts and compliance recommendations should be reviewed before use, especially for enterprise-tier or first-of-kind engagements. Indian compliance law (DPDPA rules, CERT-In penalties, GST thresholds) is actively evolving — the rules engine reflects the state of law as of mid-2026.

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

Built with Flutter by [Aanand AB](https://github.com/AanandAB)
