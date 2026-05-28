CREATE SCHEMA jobs_project;

CREATE TABLE jobs_project.bls_oes (
occ_code		VARCHAR(10),
occ_title		VARCHAR(255),
o_group			VARCHAR(20),
tot_emp			NUMERIC,
a_mean			NUMERIC
);


CREATE TABLE jobs_project.bls_projections (
    occ_title           TEXT,
    occ_code            VARCHAR(10),
    emp_2024            NUMERIC,
    emp_2034            NUMERIC,
    emp_change          NUMERIC,
    emp_pct_change      NUMERIC,
    occ_openings        NUMERIC,
    median_wage         TEXT,
    entry_edu           TEXT,
    edu_code            INTEGER,
    work_experience     TEXT,
    workex_code         INTEGER,
    ojt_training        TEXT,
    tr_code             INTEGER
);


CREATE TABLE jobs_project.bls_oes_staging (
    area            TEXT,
    area_title      TEXT,
    area_type       TEXT,
    prim_state      TEXT,
    naics           TEXT,
    naics_title     TEXT,
    i_group         TEXT,
    own_code        TEXT,
    occ_code        TEXT,
    occ_title       TEXT,
    o_group         TEXT,
    tot_emp         TEXT,
    emp_prse        TEXT,
    jobs_1000       TEXT,
    loc_quotient    TEXT,
    pct_total       TEXT,
    pct_rpt         TEXT,
    h_mean          TEXT,
    a_mean          TEXT,
    mean_prse       TEXT,
    h_pct10         TEXT,
    h_pct25         TEXT,
    h_median        TEXT,
    h_pct75         TEXT,
    h_pct90         TEXT,
    a_pct10         TEXT,
    a_pct25         TEXT,
    a_median        TEXT,
    a_pct75         TEXT,
    a_pct90         TEXT,
    annual          TEXT,
    hourly          TEXT
);


CREATE TABLE jobs_project.bls_projections_staging (
    occ_title           TEXT,
    occ_code            TEXT,
    emp_2024            TEXT,
    emp_2034            TEXT,
    emp_change          TEXT,
    emp_pct_change      TEXT,
    occ_openings        TEXT,
    median_wage         TEXT,
    entry_edu           TEXT,
    edu_code            TEXT,
    work_experience     TEXT,
    workex_code         TEXT,
    ojt_training        TEXT,
    tr_code             TEXT
);


INSERT INTO jobs_project.bls_oes (occ_code, occ_title, o_group, tot_emp, a_mean)
SELECT
    occ_code,
    occ_title,
    o_group,
    NULLIF(NULLIF(tot_emp, ''), '*')::NUMERIC,
    NULLIF(NULLIF(a_mean, ''), '*')::NUMERIC
FROM jobs_project.bls_oes_staging
WHERE o_group = 'detailed'
AND NULLIF(NULLIF(tot_emp, ''), '*') IS NOT NULL;


INSERT INTO jobs_project.bls_projections (
    occ_title, occ_code, emp_2024, emp_2034, emp_change,
    emp_pct_change, occ_openings, median_wage, entry_edu,
    edu_code, work_experience, workex_code, ojt_training, tr_code
)
SELECT
    TRIM(SPLIT_PART(occ_title, '*', 1)),
    occ_code,
    NULLIF(REPLACE(emp_2024, ',', ''), '')::NUMERIC,
    NULLIF(REPLACE(emp_2034, ',', ''), '')::NUMERIC,
    NULLIF(REPLACE(emp_change, ',', ''), '')::NUMERIC,
    NULLIF(REPLACE(emp_pct_change, ',', ''), '')::NUMERIC,
    NULLIF(REPLACE(occ_openings, ',', ''), '')::NUMERIC,
    median_wage,
    entry_edu,
    NULLIF(edu_code, '')::INTEGER,
    work_experience,
    NULLIF(workex_code, '')::INTEGER,
    ojt_training,
    NULLIF(tr_code, '')::INTEGER
FROM jobs_project.bls_projections_staging;

SELECT COUNT(*) FROM jobs_project.bls_oes;
SELECT COUNT(*) FROM jobs_project.bls_projections;

SELECT * FROM jobs_project.bls_oes LIMIT 5;
SELECT * FROM jobs_project.bls_projections LIMIT 5;


SELECT
    o.occ_code,
    o.occ_title,
    o.tot_emp,
    o.a_mean,
    p.emp_pct_change,
    p.occ_openings,
    p.median_wage,
    p.entry_edu
FROM jobs_project.bls_oes o
JOIN jobs_project.bls_projections p
    ON o.occ_code = p.occ_code;


CREATE VIEW jobs_project.job_opportunity_analysis AS
SELECT
    o.occ_code,
    o.occ_title,
    ROUND(o.tot_emp) AS current_employment,
    ROUND(p.occ_openings * 1000) AS annual_openings,
    p.emp_pct_change AS projected_growth_pct,
    ROUND(o.a_mean) AS annual_mean_wage,
    CASE
        WHEN p.median_wage = 'N/A' THEN NULL
        WHEN p.median_wage LIKE '>=%' THEN NULL
        ELSE NULLIF(REPLACE(p.median_wage, ',', ''), '')::NUMERIC
    END AS median_wage,
    p.entry_edu,
    CASE
        WHEN p.emp_pct_change >= 10 AND p.occ_openings >= 50 THEN 'High Opportunity'
        WHEN p.emp_pct_change >= 5  AND p.occ_openings >= 25 THEN 'Moderate Opportunity'
        WHEN p.emp_pct_change <= -5 THEN 'Declining'
        WHEN p.emp_pct_change <= 0  THEN 'Low Opportunity'
        ELSE 'Stable'
    END AS opportunity_label,
    ROUND(
        (p.occ_openings * 0.6) + (p.emp_pct_change * 10)
    , 1) AS opportunity_score
FROM jobs_project.bls_oes o
JOIN jobs_project.bls_projections p
    ON o.occ_code = p.occ_code
WHERE p.occ_openings IS NOT NULL
AND p.emp_pct_change IS NOT NULL;


SELECT * FROM jobs_project.job_opportunity_analysis
ORDER BY annual_openings DESC
LIMIT 20;


CREATE VIEW jobs_project.tech_job_opportunity AS
SELECT *
FROM jobs_project.job_opportunity_analysis
WHERE occ_code LIKE '15-%'
ORDER BY opportunity_score DESC;

SELECT * FROM jobs_project.tech_job_opportunity;

SELECT * FROM jobs_project.job_opportunity_analysis
ORDER BY opportunity_score DESC;

SELECT * FROM jobs_project.tech_job_opportunity
ORDER BY opportunity_score DESC;
