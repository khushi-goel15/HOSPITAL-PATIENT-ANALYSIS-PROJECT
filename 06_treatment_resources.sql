-- ============================================================================
-- 06_treatment_resources.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Analyze treatments, bed occupancy, length of stay, readmissions
-- Prerequisite: Run files 01-05 first
-- ============================================================================
-- SQL SKILLS USED:
-- SELECT, WHERE, ORDER BY, GROUP BY, HAVING
-- SUM, COUNT, AVG, MIN, MAX
-- Simple Subqueries
-- CASE WHEN
-- Self Join (for readmissions)
-- ============================================================================

USE hospital_db;

-- ============================================================================
-- QUERY 17: Top Treatments by Frequency and Cost
-- ============================================================================
-- Business Question: What are the most common and expensive treatments?
--
-- Explanation:
-- We rank treatments by how often they're performed and total cost.
-- This identifies high-volume and high-cost procedures.
--
-- Why This Matters:
-- High-frequency treatments are core operations.
-- High-cost treatments need efficiency review and pricing analysis.
--
-- SQL Concepts:
-- GROUP BY: Aggregates per treatment
-- ORDER BY: Ranks by frequency and cost
-- LIMIT: Top results only
-- ============================================================================

SELECT 
    treatment_name,
    treatment_category,
    COUNT(*) AS frequency,
    ROUND(AVG(cost), 2) AS avg_cost_per_treatment,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(MIN(cost), 2) AS min_cost,
    ROUND(MAX(cost), 2) AS max_cost
FROM Treatments
GROUP BY treatment_name, treatment_category
ORDER BY frequency DESC;

-- ============================================================================
-- QUERY 18: Category-Wise Treatment Costs
-- ============================================================================
-- Business Question: Which treatment categories cost the most?
--
-- Explanation:
-- We group treatments by category and calculate total and average costs.
-- This helps understand where the hospital spends the most.
--
-- SQL Concepts:
-- GROUP BY: Category-level aggregation
-- SUM, AVG: Cost analysis
-- Percentage calculation: Category share of total
-- ============================================================================

SELECT 
    treatment_category,
    COUNT(*) AS total_treatments,
    ROUND(SUM(cost), 2) AS total_category_cost,
    ROUND(AVG(cost), 2) AS avg_treatment_cost,
    ROUND(
        SUM(cost) * 100.0 / (SELECT SUM(cost) FROM Treatments), 2
    ) AS percentage_of_total_cost
FROM Treatments
GROUP BY treatment_category
ORDER BY total_category_cost DESC;

-- ============================================================================
-- QUERY 19: Average Length of Stay (ALOS) Per Department
-- ============================================================================
-- Business Question: Which departments have the longest patient stays?
--
-- Explanation:
-- We calculate the average number of days between admission and discharge
-- for each department. Longer stays indicate complex cases or inefficiency.
--
-- Why This Matters:
-- High ALOS may indicate:
-- - Complex case mix
-- - Inefficient discharge processes
-- - Complications during treatment
--
-- SQL Concepts:
-- DATEDIFF(): Days between admission and discharge
-- AVG(): Average calculation
-- GROUP BY: Department-level aggregation
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(adm.admission_id) AS total_admissions,
    ROUND(AVG(DATEDIFF(adm.discharge_date, adm.admission_date)), 1) AS avg_length_of_stay_days,
    MIN(DATEDIFF(adm.discharge_date, adm.admission_date)) AS min_los_days,
    MAX(DATEDIFF(adm.discharge_date, adm.admission_date)) AS max_los_days,
    SUM(CASE WHEN adm.discharge_date IS NULL THEN 1 ELSE 0 END) AS still_admitted
FROM Admissions adm
INNER JOIN Rooms r ON adm.room_id = r.room_id
INNER JOIN Departments d ON r.department_id = d.department_id
WHERE adm.discharge_date IS NOT NULL
GROUP BY d.department_id, d.department_name
ORDER BY avg_length_of_stay_days DESC;

-- ============================================================================
-- QUERY 20: Bed Occupancy Rates
-- ============================================================================
-- Business Question: How well are hospital beds being utilized?
--
-- Explanation:
-- We compare total beds to occupied beds by department.
-- Occupancy rate = occupied beds / total beds × 100
--
-- Why This Matters:
-- - High occupancy (>85%) indicates capacity strain
-- - Low occupancy indicates underutilization
-- - Helps with expansion planning and resource allocation
--
-- SQL Concepts:
-- SUM with CASE WHEN: Counts occupied vs total beds
-- Percentage calculation
-- GROUP BY: Department-level analysis
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(r.room_id) AS total_rooms,
    SUM(r.bed_count) AS total_beds,
    SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) AS occupied_beds,
    ROUND(
        SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
        / SUM(r.bed_count), 2
    ) AS occupancy_rate_pct,
    CASE
        WHEN SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
             / SUM(r.bed_count) > 90 THEN 'Critical - Need Expansion'
        WHEN SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
             / SUM(r.bed_count) > 75 THEN 'High - Monitor Closely'
        WHEN SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
             / SUM(r.bed_count) > 50 THEN 'Moderate - Optimal'
        ELSE 'Low - Underutilized'
    END AS occupancy_status
FROM Rooms r
INNER JOIN Departments d ON r.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY occupancy_rate_pct DESC;

-- ============================================================================
-- QUERY 21: Readmission Rate (Self Join on Admissions)
-- ============================================================================
-- Business Question: What percentage of patients are readmitted within 30 days?
--
-- Explanation:
-- We use a Self Join on the Admissions table to find patients who were
-- admitted, discharged, and then readmitted within 30 days.
--
-- SQL Concepts:
-- Self Join: Joins Admissions table to itself
-- DATEDIFF(): Calculates days between discharge and next admission
-- CASE WHEN: Flags readmissions
-- Percentage calculation
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(DISTINCT a1.admission_id) AS total_discharges,
    COUNT(DISTINCT CASE 
        WHEN a2.admission_id IS NOT NULL 
        AND DATEDIFF(a2.admission_date, a1.discharge_date) <= 30 
        THEN a1.admission_id 
    END) AS readmitted_within_30_days,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN a2.admission_id IS NOT NULL 
            AND DATEDIFF(a2.admission_date, a1.discharge_date) <= 30 
            THEN a1.admission_id 
        END) * 100.0 / NULLIF(COUNT(DISTINCT a1.admission_id), 0), 2
    ) AS readmission_rate_pct
FROM Admissions a1
INNER JOIN Rooms r ON a1.room_id = r.room_id
INNER JOIN Departments d ON r.department_id = d.department_id
LEFT JOIN Admissions a2 
    ON a1.patient_id = a2.patient_id 
    AND a2.admission_date > a1.discharge_date
WHERE a1.discharge_date IS NOT NULL
GROUP BY d.department_id, d.department_name
ORDER BY readmission_rate_pct DESC;

-- ============================================================================
-- QUERY 22: Diagnostic Test Volume and Cost
-- ============================================================================
-- Business Question: Which diagnostic tests are most frequently ordered?
--
-- Explanation:
-- We analyze test frequency, cost, and completion status.
-- This helps optimize lab resources and reduce costs.
--
-- SQL Concepts:
-- GROUP BY: Test-level aggregation
-- CASE WHEN: Conditional counting for status
-- ============================================================================

SELECT 
    test_name,
    COUNT(*) AS total_ordered,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(AVG(cost), 2) AS avg_cost_per_test,
    ROUND(SUM(cost), 2) AS total_test_cost
FROM Medical_Tests
GROUP BY test_name
ORDER BY total_ordered DESC;

-- ============================================================================
-- TREATMENT & RESOURCE ANALYSIS COMPLETE
-- ============================================================================
-- Key Insights:
-- - Top treatments by frequency and cost
-- - Category-wise treatment costs
-- - Average length of stay per department
-- - Bed occupancy rates
-- - Readmission rates (Self Join)
-- - Diagnostic test utilization
--
-- Next Step: Run 07_business_insights.sql for final insights
-- ============================================================================
