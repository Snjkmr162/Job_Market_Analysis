# 📊 Job Market Analysis (2024-2034)

> Which U.S. jobs have the most openings AND the strongest growth outlook? This project answers that question using BLS data, PostgreSQL, and Power BI.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![BLS Data](https://img.shields.io/badge/Data-BLS%20Official-005A8E?style=for-the-badge)
![Occupations](https://img.shields.io/badge/Occupations%20Analyzed-795-success?style=for-the-badge)

---

## 📁 Project Structure
```
job-market-analysis/
│
├── data/
│   ├── raw/                  # Original BLS source files
│   └── processed/            # Cleaned, analysis-ready CSVs
│
├── sql/                      # All SQL scripts
│
├── dashboard/                # Power BI .pbix file and screenshots
│
└── README.md
```

---

## 🗃️ Data Sources

| Source | Description | Link |
|---|---|---|
| BLS OEWS | Employment and wage data for ~800 occupations | [bls.gov/oes](https://www.bls.gov/oes/) |
| BLS Employment Projections | Projected openings and growth rates (2024-2034) | [data.bls.gov](https://data.bls.gov/projections/occupationProj) |

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Data ingestion, cleaning, joining, and opportunity scoring |
| Power BI | Interactive two-page dashboard |

---

## 🔄 SQL Workflow

1. ⬇️ Created staging tables to load raw BLS CSV files without type errors
2. 🧹 Cleaned and transformed data into final tables (filtered to detailed occupations, stripped formatting from numeric columns)
3. 🔗 Joined BLS OEWS and BLS Projections on `occ_code`
4. 🧮 Built an opportunity scoring model combining annual openings and projected growth rate
5. 👁️ Created two views: one for all 795 occupations, one filtered to tech roles (OCC code `15-XXXX`)

### Opportunity Score Formula
```sql
ROUND((occ_openings * 0.6) + (emp_pct_change * 10), 1)
```
> Openings volume is weighted at 60% and growth rate at 40%, reflecting that raw availability matters more than trajectory for near-term career decisions.

### Opportunity Labels

| Label | Criteria |
|---|---|
| 🟢 High Opportunity | Growth >= 10% AND openings >= 50k |
| 🔵 Moderate Opportunity | Growth >= 5% AND openings >= 25k |
| 🟠 Low Opportunity | Growth <= 0% |
| 🔴 Declining | Growth <= -5% |
| ⚪ Stable | Everything else |

---

## 💡 Key Findings

### 🌍 Overall Job Market
- 🏥 **Home Health and Personal Care Aides** top the opportunity score with **765,800 annual openings** and **17% projected growth**. The most underrated role in the dataset.
- 📊 **64% of all 795 occupations** are labeled Stable. The market is concentrating, not collapsing.
- 📉 **Cashiers** and **Office Clerks** are declining at -9.9% and -6.7% respectively. Automation is the primary driver.

### 💻 Tech Jobs
- ✅ **Software Developers** are the only tech role labeled High Opportunity (115,200 openings, 15.8% growth).
- 📈 **Data Scientists** have the highest growth rate in tech (33.5%) but only 23,400 openings per year. High quality, high competition.
- ⚠️ **Computer Programmers** are declining at -6% with the lowest opportunity score of any tech role (-56.7). AI displacement is already happening.

---

## 📊 Dashboard

The Power BI dashboard has two pages.

**Page 1 - Overall Job Market**
- 🔵 Scatter plot of all 795 occupations by openings vs. growth rate
- 📊 Top 10 occupations by annual openings
- 💰 Highest paying high opportunity occupations
- 🏷️ Opportunity category summary
- 🎛️ Interactive slicer to filter by opportunity label

**Page 2 - Tech Jobs Deep Dive**
- 🔵 Scatter plot of all 21 computer and mathematical occupations
- 📊 Rankings by annual openings and projected growth rate
- 📋 Full detail table with conditional formatting on growth rate

---


## 📜 License

Data sourced from the U.S. Bureau of Labor Statistics. Free to use and adapt with attribution.

---

⭐ If you found this useful, feel free to star the repo!
