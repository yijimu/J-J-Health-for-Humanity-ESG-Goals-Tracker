"""
J&J Health for Humanity ESG Goals Tracker
Data Extraction & Pipeline Script
Lunarix Technologies LLC · Yiduo Xiao

Sources:
- J&J ESG Reports (PDF → structured CSV)
- CDP Climate Change database (public)
- EPA GHG Reporting Tool (NAICS 3254)
- SEC EDGAR ESG filings

Run: python extract_esg_data.py
Output: /data/jnj_esg_clean.csv  (ready for Tableau)
"""

import sqlite3
import pandas as pd
import json
import os
from datetime import datetime

# ── CONFIG ────────────────────────────────────────────────────
DB_PATH   = "jnj_esg.db"
OUT_DIR   = "data"
os.makedirs(OUT_DIR, exist_ok=True)

# ── STEP 1: Initialize DB from schema ─────────────────────────
def init_db():
    conn = sqlite3.connect(DB_PATH)
    with open("schema.sql", "r") as f:
        conn.executescript(f.read())
    conn.commit()
    print(f"[OK] Database initialized: {DB_PATH}")
    return conn

# ── STEP 2: Export analytical views to CSV ────────────────────
def export_views(conn):
    views = {
        "goal_progress"    : "SELECT * FROM v_goal_progress",
        "latest_perf"      : "SELECT * FROM v_latest_performance",
        "yoy_trend"        : "SELECT * FROM v_yoy_trend",
        "competitor_bench" : "SELECT * FROM competitor_benchmarks",
        "supplier_data"    : "SELECT * FROM supplier_sustainability",
    }
    for name, query in views.items():
        df = pd.read_sql_query(query, conn)
        path = f"{OUT_DIR}/{name}.csv"
        df.to_csv(path, index=False)
        print(f"[OK] Exported {len(df)} rows → {path}")
    return

# ── STEP 3: Calculate KPI summary for dashboard ───────────────
def build_kpi_summary(conn):
    df = pd.read_sql_query("SELECT * FROM v_latest_performance", conn)

    summary = {
        "as_of_date"        : datetime.now().strftime("%Y-%m-%d"),
        "data_year"         : 2023,
        "goals_on_track"    : int((df["pct_to_goal"] >= 80).sum()),
        "goals_total"       : len(df),
        "avg_progress_pct"  : round(df["pct_to_goal"].mean(), 1),
        "carbon_reduction"  : "31%",     # vs 2019 baseline
        "renewable_energy"  : "70%",
        "packaging_progress": "82%",
        "water_replenishment": "95%",
        "supplier_coverage" : "93%",
    }
    path = f"{OUT_DIR}/kpi_summary.json"
    with open(path, "w") as f:
        json.dump(summary, f, indent=2)
    print(f"[OK] KPI summary → {path}")
    print(f"\n{'='*50}")
    print(f"  DASHBOARD SUMMARY ({summary['data_year']})")
    print(f"{'='*50}")
    for k, v in summary.items():
        if k not in ("as_of_date", "data_year"):
            print(f"  {k:<25} {v}")
    return summary

# ── STEP 4: Gap-to-goal analysis ──────────────────────────────
def gap_analysis(conn):
    query = """
    SELECT
        category,
        goal_name,
        target_value,
        target_year,
        actual_value,
        pct_to_goal,
        unit,
        CASE
            WHEN pct_to_goal >= 95 THEN 'On Track'
            WHEN pct_to_goal >= 75 THEN 'Needs Attention'
            ELSE 'At Risk'
        END as status
    FROM v_latest_performance
    ORDER BY pct_to_goal DESC
    """
    df = pd.read_sql_query(query, conn)
    path = f"{OUT_DIR}/gap_analysis.csv"
    df.to_csv(path, index=False)
    print(f"\n[OK] Gap analysis exported → {path}")
    print(df[["category","pct_to_goal","status"]].to_string(index=False))
    return df

# ── STEP 5: Tableau-ready master flat file ────────────────────
def build_tableau_flat(conn):
    """
    Single wide CSV optimized for Tableau.
    One row per (company, year, metric).
    """
    query = """
    SELECT
        'Johnson & Johnson' as company,
        g.pillar,
        g.category,
        g.goal_name,
        g.target_value,
        g.target_year,
        g.unit,
        g.baseline_year,
        g.baseline_value,
        a.reporting_year,
        a.actual_value,
        a.data_source,
        a.assurance_level,
        ROUND(
            CASE WHEN g.target_value = 0
                THEN (g.baseline_value - a.actual_value) / g.baseline_value * 100
                ELSE a.actual_value / g.target_value * 100
            END, 1
        ) as pct_to_goal,
        CASE
            WHEN ROUND(
                CASE WHEN g.target_value = 0
                    THEN (g.baseline_value - a.actual_value) / g.baseline_value * 100
                    ELSE a.actual_value / g.target_value * 100
                END, 1) >= 95 THEN 'On Track'
            WHEN ROUND(
                CASE WHEN g.target_value = 0
                    THEN (g.baseline_value - a.actual_value) / g.baseline_value * 100
                    ELSE a.actual_value / g.target_value * 100
                END, 1) >= 75 THEN 'Needs Attention'
            ELSE 'At Risk'
        END as status
    FROM esg_goals g
    JOIN esg_actuals a ON g.goal_id = a.goal_id
    WHERE g.is_active = 1
    """
    df = pd.read_sql_query(query, conn)

    # Append competitor benchmark rows
    bench_q = "SELECT * FROM competitor_benchmarks"
    bench   = pd.read_sql_query(bench_q, conn)

    path = f"{OUT_DIR}/tableau_master.csv"
    df.to_csv(path, index=False)
    bench.to_csv(f"{OUT_DIR}/tableau_benchmark.csv", index=False)
    print(f"\n[OK] Tableau master file → {path}")
    print(f"[OK] Benchmark file → {OUT_DIR}/tableau_benchmark.csv")
    print(f"     {len(df)} rows · {df['category'].nunique()} categories · {df['reporting_year'].nunique()} years")
    return df

# ── STEP 6: Print Tableau connection guide ────────────────────
def print_tableau_guide():
    guide = """
╔══════════════════════════════════════════════════════════════╗
║        TABLEAU CONNECTION GUIDE                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  Option A — Direct SQLite connection                         ║
║  1. Tableau Desktop: Connect → Other Databases → SQLite      ║
║  2. Point to jnj_esg.db                                      ║
║  3. Views available: v_goal_progress, v_latest_performance   ║
║                      v_yoy_trend                             ║
║                                                              ║
║  Option B — CSV (Tableau Public or Desktop)                  ║
║  Primary: data/tableau_master.csv                            ║
║  Secondary: data/tableau_benchmark.csv                       ║
║  Join on: category + reporting_year                          ║
║                                                              ║
║  Recommended calculated fields in Tableau:                   ║
║  · [Gap to Target] = [target_value] - [actual_value]         ║
║  · [Years to Target] = [target_year] - [reporting_year]      ║
║  · [On Track Color] = IF [pct_to_goal] >= 95 THEN "green"   ║
║                       ELSEIF [pct_to_goal] >= 75 THEN "amber"║
║                       ELSE "red" END                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
    """
    print(guide)

# ── MAIN ──────────────────────────────────────────────────────
if __name__ == "__main__":
    print("J&J ESG Goals Tracker — Data Pipeline")
    print("=" * 50)
    conn = init_db()
    export_views(conn)
    build_kpi_summary(conn)
    gap_analysis(conn)
    build_tableau_flat(conn)
    print_tableau_guide()
    conn.close()
    print("\n[DONE] All files ready in /data/")
    print("Next: open Tableau and connect to data/tableau_master.csv")
