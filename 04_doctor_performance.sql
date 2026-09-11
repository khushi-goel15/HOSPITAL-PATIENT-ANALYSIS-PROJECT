-- ============================================================================
-- 04_doctor_performance.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Analyze doctor performance, workload, and revenue generation
-- Prerequisite: Run files 01-03 first
-- ============================================================================
-- SQL SKILLS USED:
-- SELECT, WHERE, ORDER BY, GROUP BY, HAVING
-- SUM, COUNT, AVG, MIN, MAX
-- Simple Subqueries
-- CASE WHEN
-- ============================================================================

USE hospital_db;

-- ============================================================================
-- QUERY 7: Total Patients Treated Per Doctor
-- ============================================================================
-- Business Question: Which doctors treat the most patients?
--
-- Explanation:
-- We count distinct patients per doctor from both appointments and admissions.
-- This gives a complete picture of each doctor's patient load.
--
-- Why This Matters:
-- Identifies high-volume doctors who may need support or recognition.
-- Also identifies underutilized doctors who may need more referrals.
--
-- SQL Concepts:
-- COUNT(DISTINCT): Counts unique patients (avoids double-counting)
-- INNER JOIN: Links doctors to their appointments
-- GROUP BY: Aggregates per doctor
-- ============================================================================

SELECT 
    doc.doctor_id,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    doc.specialization,
    d.department_name,
    COUNT(DISTINCT a.patient_id) AS patients_from_appointments,
    COUNT(DISTINCT adm.patient_id) AS patients_from_admissions,
    COUNT(DISTINCT CASE 
        WHEN a.patient_id IS NOT NULL THEN a.patient_id 
        WHEN adm.patient_id IS NOT NULL THEN adm.patient_id 
    END) AS total_unique_patients
FROM Doctors doc
INNER JOIN Departments d ON doc.department_id = d.department_id
LEFT JOIN Appointments a ON doc.doctor_id = a.doctor_id AND a.appointment_status = 'Completed'
LEFT JOIN Admissions adm ON doc.doctor_id = adm.doctor_id
GROUP BY doc.doctor_id, doc.first_name, doc.last_name, doc.specialization, d.department_name
ORDER BY total_unique_patients DESC
LIMIT 15;

-- ============================================================================
-- QUERY 8: Revenue Generated Per Doctor
-- ============================================================================
-- Business Question: Which doctors generate the most revenue?
--
-- Explanation:
-- We calculate total treatment and prescription costs per doctor.
-- This helps measure the financial contribution of each physician.
--
-- Why This Matters:
-- Revenue per doctor helps with performance reviews, salary decisions,
-- and resource allocation.
--
-- SQL Concepts:
-- SUM(): Total cost aggregation
-- Multiple JOINs: Links doctors to treatments and prescriptions
-- GROUP BY: Per-doctor aggregation
-- ============================================================================

SELECT 
    doc.doctor_id,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    doc.specialization,
    d.department_name,
    ROUND(COALESCE(SUM(t.cost), 0), 2) AS treatment_revenue,
    ROUND(COALESCE(SUM(pres.cost), 0), 2) AS prescription_revenue,
    ROUND(COALESCE(SUM(t.cost), 0) + COALESCE(SUM(pres.cost), 0), 2) AS total_revenue
FROM Doctors doc
INNER JOIN Departments d ON doc.department_id = d.department_id
LEFT JOIN Treatments t ON doc.doctor_id = t.doctor_id
LEFT JOIN Prescriptions pres ON doc.doctor_id = pres.doctor_id
GROUP BY doc.doctor_id, doc.first_name, doc.last_name, doc.specialization, d.department_name
ORDER BY total_revenue DESC
LIMIT 15;

-- ============================================================================
-- QUERY 9: Rank Doctors by Patient Volume Within Each Department
-- ============================================================================
-- Business Question: Who are the top doctors in each department?
--
-- Explanation:
-- We use a subquery to rank doctors within their department by patient count.
-- This identifies department-level top performers.
--
-- SQL Concepts:
-- Subquery: Calculates patient count per doctor
-- ROW_NUMBER(): Ranks doctors within each department
-- PARTITION BY: Restarts ranking for each department
-- ============================================================================

SELECT 
    department_name,
    doctor_name,
    specialization,
    total_patients,
    department_rank
FROM (
    SELECT 
        d.department_name,
        CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
        doc.specialization,
        COUNT(DISTINCT a.patient_id) AS total_patients,
        ROW_NUMBER() OVER (
            PARTITION BY d.department_id 
            ORDER BY COUNT(DISTINCT a.patient_id) DESC
        ) AS department_rank
    FROM Doctors doc
    INNER JOIN Departments d ON doc.department_id = d.department_id
    LEFT JOIN Appointments a ON doc.doctor_id = a.doctor_id AND a.appointment_status = 'Completed'
    GROUP BY d.department_id, d.department_name, doc.doctor_id, doc.first_name, doc.last_name, doc.specialization
) AS ranked_doctors
WHERE department_rank <= 3
ORDER BY department_name, department_rank;

-- ============================================================================
-- QUERY 10: Average Length of Stay Per Doctor's Patients
-- ============================================================================
-- Business Question: Which doctors have patients with longer stays?
--
-- Explanation:
-- We calculate the average number of days between admission and discharge
-- for patients treated by each doctor.
--
-- Why This Matters:
-- Longer stays may indicate complex cases, complications, or inefficiency.
-- This metric helps identify patterns in care delivery.
--
-- SQL Concepts:
-- DATEDIFF(): Calculates days between admission and discharge
-- AVG(): Average length of stay
-- Subquery: Filters for discharged patients only
-- ============================================================================

SELECT 
    doc.doctor_id,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    d.department_name,
    COUNT(adm.admission_id) AS total_admissions,
    ROUND(AVG(DATEDIFF(adm.discharge_date, adm.admission_date)), 1) AS avg_length_of_stay_days,
    MIN(DATEDIFF(adm.discharge_date, adm.admission_date)) AS min_los,
    MAX(DATEDIFF(adm.discharge_date, adm.admission_date)) AS max_los
FROM Doctors doc
INNER JOIN Departments d ON doc.department_id = d.department_id
INNER JOIN Admissions adm ON doc.doctor_id = adm.doctor_id
WHERE adm.discharge_date IS NOT NULL
GROUP BY doc.doctor_id, doc.first_name, doc.last_name, d.department_name
HAVING COUNT(adm.admission_id) >= 5
ORDER BY avg_length_of_stay_days DESC
LIMIT 15;

-- ============================================================================
-- QUERY 11: Workload Distribution Across Specialties
-- ============================================================================
-- Business Question: How is workload distributed across medical specialties?
--
-- Explanation:
-- We calculate total patients, admissions, and treatments per specialty.
-- This reveals which specialties are overworked or underutilized.
--
-- SQL Concepts:
-- Multiple aggregations in one query
-- CASE WHEN: Conditional counting
-- GROUP BY: Specialty-level aggregation
-- ============================================================================

SELECT 
    doc.specialization,
    d.department_name,
    COUNT(DISTINCT a.patient_id) AS total_appointment_patients,
    COUNT(DISTINCT adm.patient_id) AS total_admitted_patients,
    COUNT(t.treatment_id) AS total_treatments,
    COUNT(pres.prescription_id) AS total_prescriptions,
    COUNT(DISTINCT a.patient_id) + COUNT(DISTINCT adm.patient_id) AS total_patient_load
FROM Doctors doc
INNER JOIN Departments d ON doc.department_id = d.department_id
LEFT JOIN Appointments a ON doc.doctor_id = a.doctor_id
LEFT JOIN Admissions adm ON doc.doctor_id = adm.doctor_id
LEFT JOIN Treatments t ON doc.doctor_id = t.doctor_id
LEFT JOIN Prescriptions pres ON doc.doctor_id = pres.doctor_id
GROUP BY doc.specialization, d.department_name
ORDER BY total_patient_load DESC;

-- ============================================================================
-- DOCTOR PERFORMANCE COMPLETE
-- ============================================================================
-- Key Insights:
-- - Patient volume per doctor
-- - Revenue generated per doctor
-- - Department-level doctor rankings
-- - Average length of stay by doctor
-- - Workload distribution across specialties
--
-- Next Step: Run 05_revenue_billing.sql for financial analysis
-- ============================================================================
