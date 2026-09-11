-- ============================================================================
-- 03_patient_analysis.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Analyze patient demographics, appointments, and no-show patterns
-- Prerequisite: Run 01_schema_setup.sql and 02_data_generation.sql first
-- ============================================================================
-- SQL SKILLS USED:
-- SELECT, WHERE, ORDER BY, GROUP BY, HAVING
-- SUM, COUNT, AVG, MIN, MAX
-- Simple Subqueries
-- Date Functions: YEAR(), MONTH(), DATEDIFF()
-- ============================================================================

USE hospital_db;

-- ============================================================================
-- QUERY 1: Total Appointments Per Department
-- ============================================================================
-- Business Question: Which departments have the most appointment traffic?
--
-- Explanation:
-- We join Appointments to Doctors to Departments, then group by department.
-- This shows which departments handle the most outpatient volume.
--
-- Why This Matters:
-- High-appointment departments may need more staff or extended hours.
-- Low-appointment departments may need marketing or referral programs.
--
-- SQL Concepts:
-- INNER JOIN: Links appointments through doctors to departments
-- COUNT(): Counts appointments per department
-- GROUP BY: Aggregates at the department level
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(a.appointment_id) AS total_appointments,
    COUNT(DISTINCT a.patient_id) AS unique_patients,
    ROUND(COUNT(a.appointment_id) * 100.0 / 
        (SELECT COUNT(*) FROM Appointments), 2) AS percentage_of_total
FROM Appointments a
INNER JOIN Doctors doc ON a.doctor_id = doc.doctor_id
INNER JOIN Departments d ON doc.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_appointments DESC;

-- ============================================================================
-- QUERY 2: Monthly Appointment Trends
-- ============================================================================
-- Business Question: How do appointment volumes change month by month?
--
-- Explanation:
-- We extract year and month from appointment_date, then count appointments.
-- This reveals seasonal patterns (e.g., flu season spikes).
--
-- SQL Concepts:
-- DATE_FORMAT(): Formats date as 'YYYY-MM' for grouping
-- COUNT(): Total appointments per month
-- ORDER BY: Chronological sorting
-- ============================================================================

SELECT 
    YEAR(a.appointment_date) AS appointment_year,
    MONTH(a.appointment_date) AS appointment_month,
    DATE_FORMAT(a.appointment_date, '%Y-%m') AS year_month,
    COUNT(a.appointment_id) AS total_appointments,
    COUNT(DISTINCT a.patient_id) AS unique_patients
FROM Appointments a
GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date), DATE_FORMAT(a.appointment_date, '%Y-%m')
ORDER BY appointment_year, appointment_month;

-- ============================================================================
-- QUERY 3: No-Show Rate Calculation
-- ============================================================================
-- Business Question: What percentage of appointments are no-shows?
--
-- Explanation:
-- No-shows are appointments where the patient didn't show up.
-- We calculate no-show count and rate across all appointments and by department.
--
-- Why This Matters:
-- No-shows waste doctor time and reduce revenue. High no-show rates
-- indicate need for reminder systems or scheduling improvements.
--
-- SQL Concepts:
-- CASE WHEN: Counts no-shows conditionally
-- Subquery: Calculates total appointments for percentage
-- GROUP BY: Breakdown by department
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.appointment_status = 'No-Show' THEN 1 ELSE 0 END) AS no_show_count,
    ROUND(
        SUM(CASE WHEN a.appointment_status = 'No-Show' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(a.appointment_id), 2
    ) AS no_show_rate_pct
FROM Appointments a
INNER JOIN Doctors doc ON a.doctor_id = doc.doctor_id
INNER JOIN Departments d ON doc.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(a.appointment_id) > 100
ORDER BY no_show_rate_pct DESC;

-- ============================================================================
-- QUERY 4: Patient Demographics - Age and Gender Segmentation
-- ============================================================================
-- Business Question: What does our patient population look like?
--
-- Explanation:
-- We calculate age from date_of_birth and segment by age groups and gender.
-- This helps understand who our patients are.
--
-- SQL Concepts:
-- DATEDIFF(): Calculates age in days, divided by 365.25 for years
-- CASE WHEN: Creates age group segments
-- GROUP BY: Aggregates by gender and age group
-- ============================================================================

SELECT 
    p.gender,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) < 18 THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) BETWEEN 36 AND 50 THEN '36-50'
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) BETWEEN 51 AND 65 THEN '51-65'
        ELSE 'Over 65'
    END AS age_group,
    COUNT(DISTINCT p.patient_id) AS patient_count,
    ROUND(COUNT(DISTINCT p.patient_id) * 100.0 / 
        (SELECT COUNT(*) FROM Patients), 2) AS percentage
FROM Patients p
GROUP BY p.gender, age_group
ORDER BY p.gender, age_group;

-- ============================================================================
-- QUERY 5: Average Wait Time (Appointment Duration Proxy)
-- ============================================================================
-- Business Question: How long do patients wait for appointments?
--
-- Explanation:
-- We calculate the gap between registration date and first appointment.
-- This serves as a proxy for wait time in outpatient settings.
--
-- SQL Concepts:
-- Subquery: Finds first appointment per patient
-- DATEDIFF(): Calculates days between dates
-- AVG(): Average wait time
-- ============================================================================

SELECT 
    d.department_name,
    ROUND(AVG(DATEDIFF(a.appointment_date, p.registration_date)), 1) AS avg_wait_days,
    MIN(DATEDIFF(a.appointment_date, p.registration_date)) AS min_wait_days,
    MAX(DATEDIFF(a.appointment_date, p.registration_date)) AS max_wait_days
FROM Appointments a
INNER JOIN Doctors doc ON a.doctor_id = doc.doctor_id
INNER JOIN Departments d ON doc.department_id = d.department_id
INNER JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.appointment_status = 'Completed'
GROUP BY d.department_id, d.department_name
ORDER BY avg_wait_days DESC;

-- ============================================================================
-- QUERY 6: Appointment Status Summary
-- ============================================================================
-- Business Question: What is the overall appointment completion rate?
--
-- Explanation:
-- We summarize all appointment statuses to understand operational efficiency.
--
-- SQL Concepts:
-- CASE WHEN: Conditional counting
-- GROUP BY: Status breakdown
-- Percentage calculation
-- ============================================================================

SELECT 
    appointment_status,
    COUNT(*) AS appointment_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Appointments), 2) AS percentage
FROM Appointments
GROUP BY appointment_status
ORDER BY appointment_count DESC;

-- ============================================================================
-- PATIENT ANALYSIS COMPLETE
-- ============================================================================
-- Key Insights:
-- - Department-wise appointment volume
-- - Monthly appointment trends
-- - No-show rates by department
-- - Patient age and gender distribution
-- - Average wait times by department
-- - Overall appointment status distribution
--
-- Next Step: Run 04_doctor_performance.sql for doctor-level analysis
-- ============================================================================
