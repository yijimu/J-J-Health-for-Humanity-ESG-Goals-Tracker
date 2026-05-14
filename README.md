# J&J Health for Humanity — ESG Goals Tracker

> Live ESG analytics platform tracking Johnson & Johnson's Health for Humanity goals across carbon, packaging, water, and supplier sustainability — with peer benchmarking against Merck, BMS, and Pfizer.

**Live dashboard:** [lunariduo.com/jnj_esg_tracker.html](https://lunariduo.com/jnj_esg_tracker.html)
**Author:** Yiduo Xiao · Lunarix Technologies LLC · [yijimu@lunariduo.com](mailto:yijimu@lunariduo.com)
**Frameworks:** CDP · SEC EDGAR · EPA GHGRP · SASB Pharmaceutical Standard

---

## Problem

J&J publishes five "Health for Humanity" goals — carbon reduction, renewable energy, recyclable packaging, water replenishment, supplier sustainability — but no single view reconciles them against peer pharma performance. ESG teams, sustainability analysts, and external benchmarking groups need a consolidated, year-by-year trajectory view with peer context.

## Approach

End-to-end pipeline from public disclosure to interactive dashboard:

1. **Ingestion** — Python ETL pulls 5-year ESG disclosures from SEC EDGAR (10-K, proxy), CDP Climate Change responses, EPA GHGRP (NAICS 3254), and competitor public reports.
2. **Schema** — SQLite/PostgreSQL star schema: `esg_goals` (dim) · `esg_actuals` (fact) · `competitor_benchmarks` · `supplier_sustainability`. Data contracts enforce unit normalization (MT CO₂e), assurance level tagging (third-party vs. management estimate).
3. **Risk scoring** — Composite ESG score weighted per SASB pharma materiality.
4. **Visualization** — Chart.js dashboard with year filter and net-zero pathway overlay; Tableau-ready master CSV for executive reporting.

## Findings & Outcome

- **Scope 3 (supplier-driven) emissions** are the largest decarbonization gap for J&J — consistent with peer pharma.
- J&J's renewable-energy goal is on-track; **water replenishment is behind** its 2030 commitment trajectory.
- Recyclable packaging shows steady YoY improvement, narrowing the gap with Merck.
- Dashboard surfaces these gaps within 30 seconds of opening — usable for an ESG-team baseline review meeting.

---

## Tech stack

| Layer | Tool |
|---|---|
| Database | SQLite / PostgreSQL |
| ETL | Python 3.10+ (`pandas`, `sqlite3`, `requests`) |
| Visualization | Chart.js 4.4 (embedded HTML) |
| Reporting | Tableau-ready CSV export |

## Project structure

```
project_01_jnj_esg_tracker/
├── README.md                     # this file
├── LICENSE                       # MIT
├── .gitignore
├── index.html                    # live Chart.js dashboard
├── schema.sql                    # PostgreSQL/SQLite DDL
├── extract_esg_data.py           # ETL pipeline
└── data/
    └── tableau_master.csv        # cleaned export for Tableau
```

## Quick start

```bash
# 1. Clone
git clone https://github.com/yiduo194/project_01_jnj_esg_tracker.git
cd project_01_jnj_esg_tracker

# 2. Set up SQLite DB
sqlite3 jnj_esg.db < schema.sql

# 3. Run the ETL pipeline
python extract_esg_data.py
# → writes data/jnj_esg_clean.csv

# 4. Open the dashboard
open index.html       # macOS
# or just double-click index.html
```

## Data sources (all public)

- [SEC EDGAR](https://www.sec.gov/edgar) — annual 10-K / proxy statements
- [CDP Climate Change](https://www.cdp.net) — voluntary corporate climate disclosure
- [EPA GHG Reporting Tool](https://www.epa.gov/ghgreporting) — facility-level NAICS 3254 emissions
- J&J Health for Humanity Reports (publicly archived)

## Limitations

- ESG composite scores are **my synthesis** of public disclosures + SASB pharma materiality weights — they will not match any single rating agency exactly.
- Supplier-level granularity is reported in aggregate by J&J; supplier-by-supplier data is not publicly disclosed.
- 2024–2025 disclosures will require re-running the ETL when new annual reports are published.

## License

MIT — see [LICENSE](LICENSE).

---

**About Lunarix Technologies LLC** — an independent BI / data-governance consultancy based in Edison, NJ. Building audit-defensible analytics for pharma, healthcare, and supply chain clients. More work at [lunariduo.com](https://lunariduo.com).
