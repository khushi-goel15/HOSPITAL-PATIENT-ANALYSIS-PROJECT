-- ============================================================================
-- 05_revenue_billing.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Analyze revenue, billing efficiency, and insurance coverage
-- Prerequisite: Run files 01-04 first
-- ============================================================================
-- SQL SKILLS USED:
-- SELECT, WHERE, ORDER BY, GROUP BY, HAVING
-- SUM, COUNT, AVG, MIN, MAX
-- Simple Subqueries
-- CASE WHEN
-- Date Functions
-- ============================================================================

USE hospital_db;

-- ============================================================================
-- QUERY 12: Total Revenue Generated
-- ============================================================================
-- Business Question: How much total revenue has the hospital generated?
--
-- Explanation:
-- We sum all bill amounts and payment amounts.
-- Revenue = sum of all bills; Collections = sum of all payments.
--
-- Why This Matters:
-- The gap between bills and payments shows outstanding revenue
-- that needs to be collected.
--
-- SQL Concepts:
-- SUM(): Total aggregation
-- Subquery: Calculates total bills and payments separately
-- ============================================================================

SELECT 
    'Total Billed' AS metric,
    ROUND(SUM(total_amount), 2) AS amount
FROM Bills
UNION ALL
SELECT 
    'Total Insurance Covered',
    ROUND(SUM(insurance_covered), 2)
FROM Bills
UNION ALL
SELECT 
    'Total Patient Responsibility',
    ROUND(SUM(patient_responsibility), 2)
FROM Bills
UNION ALL
SELECT 
    'Total Payments Collected',
    ROUND(SUM(payment_amount), 2)
FROM Payments;

-- ============================================================================
-- QUERY 13: Monthly Revenue and Growth Trends
-- ============================================================================
-- Business Question: How does revenue change month by month?
--
-- Explanation:
-- We group bills by month and calculate monthly totals.
-- This reveals revenue patterns and growth trends.
--
-- SQL Concepts:
-- DATE_FORMAT(): Groups by year-month
-- SUM(): Monthly revenue aggregation
-- ORDER BY: Chronological sorting
-- ============================================================================

SELECT 
    YEAR(b.bill_date) AS bill_year,
    MONTH(b.bill_date) AS bill_month,
    DATE_FORMAT(b.bill_date, '%Y-%m') AS year_month,
    COUNT(b.bill_id) AS total_bills,
    ROUND(SUM(b.total_amount), 2) AS total_billed,
    ROUND(SUM(b.insurance_covered), 2) AS insurance_covered,
    ROUND(SUM(b.patient_responsibility), 2) AS patient_responsibility
FROM Bills b
GROUP BY YEAR(b.bill_date), MONTH(b.bill_date), DATE_FORMAT(b.bill_date, '%Y-%m')
ORDER BY bill_year, bill_month;

-- ============================================================================
-- QUERY 14: Average Bill Amount Per Patient
-- ============================================================================
-- Business Question: What is the average billing per patient?
--
-- Explanation:
-- We calculate average bill amount per patient across all their admissions.
-- This identifies high-cost patients and cost patterns.
--
-- SQL Concepts:
-- AVG(): Average calculation
-- GROUP BY: Per-patient aggregation
-- Subquery: Calculates hospital-wide average for comparison
-- ============================================================================

SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COUNT(b.bill_id) AS total_bills,
    ROUND(SUM(b.total_amount), 2) AS total_billed,
    ROUND(AVG(b.total_amount), 2) AS avg_bill_per_patient,
    (SELECT ROUND(AVG(total_amount), 2) FROM Bills) AS hospital_avg_bill
FROM Bills b
INNER JOIN Patients p ON b.patient_id = p.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY total_billed DESC
LIMIT 20;

-- ============================================================================
-- QUERY 15: Outstanding Revenue (Bills vs. Payments)
-- ============================================================================
-- Business Question: How much revenue is still outstanding?
--
-- Explanation:
-- We compare total billed against total collected for each patient.
-- The difference shows what's still owed.
--
-- Why This Matters:
-- Outstanding revenue impacts cash flow and hospital finances.
-- Identifying patients with large outstanding balances helps
-- prioritize collection efforts.
--
-- SQL Concepts:
-- Subquery: Calculates total payments per patient
-- LEFT JOIN: Includes patients with no payments
-- COALESCE: Handles NULL values for patients with no payments
-- ============================================================================

SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COALESCE(bill_summary.total_billed, 0) AS total_billed,
    COALESCE(payment_summary.total_paid, 0) AS total_paid,
    COALESCE(bill_summary.total_billed, 0) - COALESCE(payment_summary.total_paid, 0) AS outstanding_amount,
    CASE
        WHEN COALESCE(bill_summary.total_billed, 0) - COALESCE(payment_summary.total_paid, 0) > 10000 THEN 'High Priority'
        WHEN COALESCE(bill_summary.total_billed, 0) - COALESCE(payment_summary.total_paid, 0) > 5000 THEN 'Medium Priority'
        WHEN COALESCE(bill_summary.total_billed, 0) - COALESCE(payment_summary.total_paid, 0) > 0 THEN 'Low Priority'
        ELSE 'Fully Paid'
    END AS collection_priority
FROM Patients p
LEFT JOIN (
    SELECT patient_id, SUM(total_amount) AS total_billed
    FROM Bills
    GROUP BY patient_id
) AS bill_summary ON p.patient_id = bill_summary.patient_id
LEFT JOIN (
    SELECT patient_id, SUM(payment_amount) AS total_paid
    FROM Payments
    GROUP BY patient_id
) AS payment_summary ON p.patient_id = payment_summary.patient_id
WHERE COALESCE(bill_summary.total_billed, 0) > 0
ORDER BY outstanding_amount DESC
LIMIT 20;

-- ============================================================================
-- QUERY 16: Insurance Coverage vs. Patient Responsibility
-- ============================================================================
-- Business Question: How much do patients pay out of pocket vs. insurance?
--
-- Explanation:
-- We analyze the split between insurance coverage and patient responsibility.
-- This shows the financial burden on patients.
--
-- SQL Concepts:
-- SUM(): Total aggregation
-- Percentage calculation
-- CASE WHEN: Labels coverage levels
-- ============================================================================

SELECT 
    i.provider_name,
    COUNT(DISTINCT i.patient_id) AS patients_covered,
    ROUND(AVG(i.coverage_percentage), 2) AS avg_coverage_pct,
    ROUND(SUM(b.total_amount), 2) AS total_billed,
    ROUND(SUM(b.insurance_covered), 2) AS total_insurance_covered,
    ROUND(SUM(b.patient_responsibility), 2) AS total_patient_responsibility,
    ROUND(
        SUM(b.insurance_covered) * 100.0 / NULLIF(SUM(b.total_amount), 0), 2
    ) AS actual_coverage_pct
FROM Insurance i
INNER JOIN Bills b ON i.patient_id = b.patient_id
GROUP BY i.provider_name
ORDER BY actual_coverage_pct DESC;

-- ============================================================================
-- REVENUE & BILLING COMPLETE
-- ============================================================================
-- Key Insights:
-- - Total revenue billed, covered, and collected
-- - Monthly revenue trends
-- - Average bill per patient
-- - Outstanding revenue by patient
-- - Insurance coverage effectiveness
--
-- Next Step: Run 06_treatment_resources.sql for treatment analysis
-- ============================================================================
