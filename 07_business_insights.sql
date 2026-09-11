-- ============================================================================
-- 07_business_insights.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Final business insights and actionable recommendations
-- Prerequisite: Run files 01-06 first
-- ============================================================================
-- This file answers all key business questions and provides
-- actionable insights for hospital management.
-- ============================================================================

USE hospital_db;

-- ============================================================================
-- INSIGHT 1: Which departments generate the most revenue?
-- ============================================================================
-- Business Question: Where does the hospital make the most money?
--
-- Business Insight:
-- This query reveals which departments are the primary revenue drivers.
-- High-revenue departments should receive continued investment and support.
-- Low-revenue departments may need marketing, referrals, or service expansion.
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(DISTINCT adm.admission_id) AS total_admissions,
    ROUND(COALESCE(SUM(t.cost), 0), 2) AS treatment_revenue,
    ROUND(COALESCE(SUM(pres.cost), 0), 2) AS prescription_revenue,
    ROUND(COALESCE(SUM(mt.cost), 0), 2) AS test_revenue,
    ROUND(
        COALESCE(SUM(t.cost), 0) + COALESCE(SUM(pres.cost), 0) + COALESCE(SUM(mt.cost), 0), 2
    ) AS total_department_revenue
FROM Departments d
LEFT JOIN Admissions adm ON d.department_id = (
    SELECT department_id FROM Rooms WHERE room_id = adm.room_id
)
LEFT JOIN Treatments t ON adm.admission_id = t.admission_id
LEFT JOIN Prescriptions pres ON adm.admission_id = pres.admission_id
LEFT JOIN Medical_Tests mt ON adm.admission_id = mt.admission_id
GROUP BY d.department_id, d.department_name
ORDER BY total_department_revenue DESC;

-- ============================================================================
-- INSIGHT 2: Which doctors have the highest patient load?
-- ============================================================================
-- Business Question: Who are the busiest doctors?
--
-- Business Insight:
-- Identifies doctors with the highest patient volumes. These doctors
-- may need additional support staff or reduced schedules to prevent burnout.
-- Their expertise should be leveraged for training and mentorship programs.
-- ============================================================================

SELECT 
    doc.doctor_id,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    doc.specialization,
    d.department_name,
    COUNT(DISTINCT a.patient_id) AS appointment_patients,
    COUNT(DISTINCT adm.patient_id) AS admitted_patients,
    COUNT(DISTINCT a.patient_id) + COUNT(DISTINCT adm.patient_id) AS total_patient_load
FROM Doctors doc
INNER JOIN Departments d ON doc.department_id = d.department_id
LEFT JOIN Appointments a ON doc.doctor_id = a.doctor_id
LEFT JOIN Admissions adm ON doc.doctor_id = adm.doctor_id
GROUP BY doc.doctor_id, doc.first_name, doc.last_name, doc.specialization, d.department_name
ORDER BY total_patient_load DESC
LIMIT 10;

-- ============================================================================
-- INSIGHT 3: What is the financial impact of no-shows?
-- ============================================================================
-- Business Question: How much revenue is lost due to patient no-shows?
--
-- Business Insight:
-- Calculates the potential revenue lost from no-show appointments.
-- This quantifies the cost of no-shows and justifies investment in
-- reminder systems, flexible scheduling, and patient engagement programs.
-- ============================================================================

SELECT 
    d.department_name,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.appointment_status = 'No-Show' THEN 1 ELSE 0 END) AS no_show_count,
    ROUND(
        SUM(CASE WHEN a.appointment_status = 'No-Show' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(a.appointment_id), 2
    ) AS no_show_rate_pct,
    ROUND(
        SUM(CASE WHEN a.appointment_status = 'No-Show' THEN 1 ELSE 0 END) * 150, 2
    ) AS estimated_revenue_lost
FROM Appointments a
INNER JOIN Doctors doc ON a.doctor_id = doc.doctor_id
INNER JOIN Departments d ON doc.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY no_show_rate_pct DESC;

-- ============================================================================
-- INSIGHT 4: Which treatments are the most cost-intensive?
-- ============================================================================
-- Business Question: Where is the hospital spending the most on treatments?
--
-- Business Insight:
-- Identifies the most expensive treatment categories. High-cost treatments
-- should be reviewed for efficiency, pricing optimization, and potential
-- alternatives that deliver similar outcomes at lower cost.
-- ============================================================================

SELECT 
    treatment_category,
    treatment_name,
    COUNT(*) AS frequency,
    ROUND(AVG(cost), 2) AS avg_cost,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(
        SUM(cost) * 100.0 / (SELECT SUM(cost) FROM Treatments), 2
    ) AS pct_of_total_cost
FROM Treatments
GROUP BY treatment_category, treatment_name
ORDER BY total_cost DESC
LIMIT 15;

-- ============================================================================
-- INSIGHT 5: Where should the hospital focus to improve efficiency?
-- ============================================================================
-- Business Question: What operational improvements would have the biggest impact?
--
-- Business Insight:
-- This query combines bed occupancy, readmission rates, and average length
-- of stay to identify departments needing operational improvements.
-- High occupancy + high readmissions = need for process optimization.
-- ============================================================================

SELECT 
    d.department_name,
    ROUND(
        SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
        / SUM(r.bed_count), 2
    ) AS occupancy_rate_pct,
    ROUND(AVG(DATEDIFF(adm.discharge_date, adm.admission_date)), 1) AS avg_los_days,
    COUNT(adm.admission_id) AS total_admissions,
    CASE
        WHEN SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
             / SUM(r.bed_count) > 85 
        AND AVG(DATEDIFF(adm.discharge_date, adm.admission_date)) > 7 
        THEN 'HIGH PRIORITY - Capacity & Efficiency Issues'
        WHEN SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
             / SUM(r.bed_count) > 85 
        THEN 'MEDIUM PRIORITY - Capacity Constraints'
        WHEN AVG(DATEDIFF(adm.discharge_date, adm.admission_date)) > 7 
        THEN 'MEDIUM PRIORITY - Length of Stay Issues'
        ELSE 'LOW PRIORITY - Operating Efficiently'
    END AS improvement_priority
FROM Departments d
LEFT JOIN Rooms r ON d.department_id = r.department_id
LEFT JOIN Admissions adm ON r.room_id = adm.room_id
GROUP BY d.department_id, d.department_name
ORDER BY 
    CASE
        WHEN SUM(CASE WHEN r.is_occupied = TRUE THEN r.bed_count ELSE 0 END) * 100.0 
             / SUM(r.bed_count) > 85 
        AND AVG(DATEDIFF(adm.discharge_date, adm.admission_date)) > 7 
        THEN 1
        ELSE 2
    END,
    occupancy_rate_pct DESC;

-- ============================================================================
-- INSIGHT 6: Patient Demographics Summary
-- ============================================================================
-- Business Question: Who are our patients?
--
-- Business Insight:
-- Understanding patient demographics helps tailor services, marketing,
-- and care programs. Age and gender distribution reveals which populations
-- the hospital serves most frequently.
-- ============================================================================

SELECT 
    CASE
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18 THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 36 AND 50 THEN '36-50'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 51 AND 65 THEN '51-65'
        ELSE 'Over 65'
    END AS age_group,
    gender,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Patients), 2) AS percentage
FROM Patients
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- ============================================================================
-- INSIGHT 7: Insurance Provider Performance
-- ============================================================================
-- Business Question: Which insurance providers cover the most patients?
--
-- Business Insight:
-- Identifies which insurance partners are most common. This helps with
-- contract negotiations, billing optimization, and understanding patient
-- financial backgrounds.
-- ============================================================================

SELECT 
    provider_name,
    COUNT(DISTINCT patient_id) AS patients_covered,
    ROUND(AVG(coverage_percentage), 2) AS avg_coverage_pct,
    ROUND(AVG(max_coverage), 2) AS avg_max_coverage,
    ROUND(
        COUNT(DISTINCT patient_id) * 100.0 / (SELECT COUNT(*) FROM Patients), 2
    ) AS pct_of_all_patients
FROM Insurance
GROUP BY provider_name
ORDER BY patients_covered DESC;

-- ============================================================================
-- INSIGHT 8: Monthly Revenue Growth Rate
-- ============================================================================
-- Business Question: Is the hospital's revenue growing or declining?
--
-- Business Insight:
-- Calculates month-over-month revenue growth. Positive growth indicates
-- business expansion; negative growth signals need for strategic changes.
-- ============================================================================

SELECT 
    year_month,
    total_billed,
    prev_month_billed,
    ROUND(total_billed - prev_month_billed, 2) AS growth_amount,
    ROUND(
        (total_billed - prev_month_billed) / NULLIF(prev_month_billed, 0) * 100, 2
    ) AS growth_percentage
FROM (
    SELECT 
        DATE_FORMAT(b.bill_date, '%Y-%m') AS year_month,
        SUM(b.total_amount) AS total_billed,
        LAG(SUM(b.total_amount)) OVER (ORDER BY DATE_FORMAT(b.bill_date, '%Y-%m')) AS prev_month_billed
    FROM Bills b
    GROUP BY DATE_FORMAT(b.bill_date, '%Y-%m')
) AS monthly_revenue
ORDER BY year_month;

-- ============================================================================
-- BUSINESS INSIGHTS COMPLETE
-- ============================================================================
-- Summary of Key Findings:
--
-- 1. DEPARTMENT REVENUE: Identified top revenue-generating departments
-- 2. DOCTOR WORKLOAD: Found busiest doctors needing support
-- 3. NO-SHOW IMPACT: Quantified financial loss from no-shows
-- 4. COST-INTENSIVE TREATMENTS: Identified expensive treatment categories
-- 5. EFFICIENCY GAPS: Found departments needing operational improvements
-- 6. PATIENT DEMOGRAPHICS: Mapped patient population characteristics
-- 7. INSURANCE PERFORMANCE: Analyzed insurance provider distribution
-- 8. REVENUE GROWTH: Tracked month-over-month financial trends
--
-- Business Recommendations:
-- - Implement automated reminder systems for high no-show departments
-- - Add support staff for highest-workload doctors
-- - Review pricing and efficiency of cost-intensive treatments
-- - Expand capacity in high-occupancy departments
-- - Optimize discharge processes to reduce length of stay
-- - Target marketing to underperforming departments
-- - Strengthen partnerships with top insurance providers
--
-- ============================================================================
-- PROJECT COMPLETE
-- ============================================================================
