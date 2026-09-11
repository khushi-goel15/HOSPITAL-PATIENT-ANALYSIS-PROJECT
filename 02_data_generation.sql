-- ============================================================================
-- 02_data_generation.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Generate realistic mock data for the hospital database
-- Prerequisite: Run 01_schema_setup.sql first
-- ============================================================================
-- DATA GENERATION TECHNIQUE:
--
-- We use a Numbers helper table with INSERT...SELECT to generate rows.
-- Instead of writing thousands of INSERT statements, we:
-- 1. Create a numbers table (1 to 5,000)
-- 2. Use INSERT...SELECT with mathematical formulas to generate data
-- 3. Use subqueries to pick random foreign keys
-- 4. Use CASE WHEN to assign realistic values
-- ============================================================================

USE hospital_db;

-- ============================================================================
-- STEP 1: Create Numbers Helper Table
-- ============================================================================

CREATE TABLE IF NOT EXISTS Numbers (
    n INT PRIMARY KEY
);

INSERT INTO Numbers (n)
WITH RECURSIVE num_seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM num_seq WHERE n < 5000
)
SELECT n FROM num_seq;

-- ============================================================================
-- STEP 2: Insert Departments
-- ============================================================================

INSERT INTO Departments (department_name, location) VALUES
('Cardiology', 'Building A, Floor 3'),
('Neurology', 'Building A, Floor 4'),
('Orthopedics', 'Building B, Floor 2'),
('Pediatrics', 'Building C, Floor 1'),
('Oncology', 'Building A, Floor 5'),
('Emergency', 'Building D, Floor 1'),
('General Surgery', 'Building B, Floor 3'),
('Radiology', 'Building E, Floor 1'),
('Dermatology', 'Building C, Floor 2'),
('Gastroenterology', 'Building A, Floor 2'),
('Pulmonology', 'Building A, Floor 1'),
('Nephrology', 'Building B, Floor 1'),
('Ophthalmology', 'Building C, Floor 3'),
('ENT', 'Building C, Floor 4'),
('Psychiatry', 'Building F, Floor 1');

-- ============================================================================
-- STEP 3: Insert Doctors (50 doctors)
-- ============================================================================

INSERT INTO Doctors (first_name, last_name, specialization, department_id, hire_date, salary, email, phone)
SELECT
    CASE MOD(n, 10)
        WHEN 0 THEN 'James' WHEN 1 THEN 'Sarah' WHEN 2 THEN 'Michael'
        WHEN 3 THEN 'Emily' WHEN 4 THEN 'David' WHEN 5 THEN 'Lisa'
        WHEN 6 THEN 'Robert' WHEN 7 THEN 'Jennifer' WHEN 8 THEN 'William'
        WHEN 9 THEN 'Maria'
    END AS first_name,
    CASE MOD(n, 8)
        WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams'
        WHEN 3 THEN 'Brown' WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia'
        WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
    END AS last_name,
    CASE MOD(n, 15)
        WHEN 0 THEN 'Cardiologist' WHEN 1 THEN 'Neurologist' WHEN 2 THEN 'Orthopedic Surgeon'
        WHEN 3 THEN 'Pediatrician' WHEN 4 THEN 'Oncologist' WHEN 5 THEN 'Emergency Physician'
        WHEN 6 THEN 'General Surgeon' WHEN 7 THEN 'Radiologist' WHEN 8 THEN 'Dermatologist'
        WHEN 9 THEN 'Gastroenterologist' WHEN 10 THEN 'Pulmonologist' WHEN 11 THEN 'Nephrologist'
        WHEN 12 THEN 'Ophthalmologist' WHEN 13 THEN 'ENT Specialist' WHEN 14 THEN 'Psychiatrist'
    END AS specialization,
    (MOD(n, 15) + 1) AS department_id,
    DATE_ADD('2015-01-01', INTERVAL FLOOR(RAND() * 2500) DAY) AS hire_date,
    ROUND(120000 + RAND() * 180000, 2) AS salary,
    CONCAT(LOWER(CASE MOD(n, 10)
        WHEN 0 THEN 'james' WHEN 1 THEN 'sarah' WHEN 2 THEN 'michael'
        WHEN 3 THEN 'emily' WHEN 4 THEN 'david' WHEN 5 THEN 'lisa'
        WHEN 6 THEN 'robert' WHEN 7 THEN 'jennifer' WHEN 8 THEN 'william'
        WHEN 9 THEN 'maria'
    END), '.', LOWER(CASE MOD(n, 8)
        WHEN 0 THEN 'smith' WHEN 1 THEN 'johnson' WHEN 2 THEN 'williams'
        WHEN 3 THEN 'brown' WHEN 4 THEN 'jones' WHEN 5 THEN 'garcia'
        WHEN 6 THEN 'miller' WHEN 7 THEN 'davis'
    END), n, '@hospital.com') AS email,
    CONCAT('555-', LPAD(FLOOR(RAND() * 1000), 3, '0'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0')) AS phone
FROM Numbers
WHERE n <= 50;

-- ============================================================================
-- STEP 4: Insert Patients (2,000 patients)
-- ============================================================================

INSERT INTO Patients (first_name, last_name, date_of_birth, gender, email, phone, address, city, state, emergency_contact_name, emergency_contact_phone, registration_date)
SELECT
    CASE MOD(n, 12)
        WHEN 0 THEN 'John' WHEN 1 THEN 'Emma' WHEN 2 THEN 'Michael'
        WHEN 3 THEN 'Olivia' WHEN 4 THEN 'William' WHEN 5 THEN 'Sophia'
        WHEN 6 THEN 'Benjamin' WHEN 7 THEN 'Isabella' WHEN 8 THEN 'Lucas'
        WHEN 9 THEN 'Mia' WHEN 10 THEN 'Henry' WHEN 11 THEN 'Charlotte'
    END AS first_name,
    CASE MOD(n, 10)
        WHEN 0 THEN 'Anderson' WHEN 1 THEN 'Thomas' WHEN 2 THEN 'Jackson'
        WHEN 3 THEN 'White' WHEN 4 THEN 'Harris' WHEN 5 THEN 'Martin'
        WHEN 6 THEN 'Thompson' WHEN 7 THEN 'Garcia' WHEN 8 THEN 'Martinez'
        WHEN 9 THEN 'Robinson'
    END AS last_name,
    DATE_ADD('1940-01-01', INTERVAL FLOOR(RAND() * 27000) DAY) AS date_of_birth,
    CASE WHEN RAND() < 0.52 THEN 'Male' ELSE 'Female' END AS gender,
    CONCAT(LOWER(CASE MOD(n, 12)
        WHEN 0 THEN 'john' WHEN 1 THEN 'emma' WHEN 2 THEN 'michael'
        WHEN 3 THEN 'olivia' WHEN 4 THEN 'william' WHEN 5 THEN 'sophia'
        WHEN 6 THEN 'benjamin' WHEN 7 THEN 'isabella' WHEN 8 THEN 'lucas'
        WHEN 9 THEN 'mia' WHEN 10 THEN 'henry' WHEN 11 THEN 'charlotte'
    END), '.', LOWER(CASE MOD(n, 10)
        WHEN 0 THEN 'anderson' WHEN 1 THEN 'thomas' WHEN 2 THEN 'jackson'
        WHEN 3 THEN 'white' WHEN 4 THEN 'harris' WHEN 5 THEN 'martin'
        WHEN 6 THEN 'thompson' WHEN 7 THEN 'garcia' WHEN 8 THEN 'martinez'
        WHEN 9 THEN 'robinson'
    END), n, '@email.com') AS email,
    CONCAT('555-', LPAD(FLOOR(RAND() * 1000), 3, '0'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0')) AS phone,
    CONCAT(FLOOR(100 + RAND() * 9900), ' ',
           CASE FLOOR(RAND() * 5)
               WHEN 0 THEN 'Main St' WHEN 1 THEN 'Oak Ave' WHEN 2 THEN 'Pine Rd'
               WHEN 3 THEN 'Elm Blvd' ELSE 'Cedar Ln'
           END) AS address,
    CASE MOD(n, 8)
        WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego'
    END AS city,
    CASE MOD(n, 8)
        WHEN 0 THEN 'NY' WHEN 1 THEN 'CA' WHEN 2 THEN 'IL'
        WHEN 3 THEN 'TX' WHEN 4 THEN 'AZ' WHEN 5 THEN 'PA'
        WHEN 6 THEN 'TX' WHEN 7 THEN 'CA'
    END AS state,
    CONCAT('Contact_', MOD(n + 100, 200)) AS emergency_contact_name,
    CONCAT('555-', LPAD(FLOOR(RAND() * 1000), 3, '0'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0')) AS emergency_contact_phone,
    DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1500) DAY) AS registration_date
FROM Numbers
WHERE n <= 2000;

-- ============================================================================
-- STEP 5: Insert Nurses (80 nurses)
-- ============================================================================

INSERT INTO Nurses (first_name, last_name, department_id, shift, hire_date, salary, phone)
SELECT
    CASE MOD(n, 8)
        WHEN 0 THEN 'Rachel' WHEN 1 THEN 'Amanda' WHEN 2 THEN 'Jessica'
        WHEN 3 THEN 'Ashley' WHEN 4 THEN 'Stephanie' WHEN 5 THEN 'Nicole'
        WHEN 6 THEN 'Samantha' WHEN 7 THEN 'Katherine'
    END AS first_name,
    CASE MOD(n, 6)
        WHEN 0 THEN 'Green' WHEN 1 THEN 'Baker' WHEN 2 THEN 'Adams'
        WHEN 3 THEN 'Nelson' WHEN 4 THEN 'Hill' WHEN 5 THEN 'Campbell'
    END AS last_name,
    (MOD(n, 15) + 1) AS department_id,
    CASE MOD(n, 3)
        WHEN 0 THEN 'Morning' WHEN 1 THEN 'Afternoon' ELSE 'Night'
    END AS shift,
    DATE_ADD('2016-01-01', INTERVAL FLOOR(RAND() * 2200) DAY) AS hire_date,
    ROUND(55000 + RAND() * 35000, 2) AS salary,
    CONCAT('555-', LPAD(FLOOR(RAND() * 1000), 3, '0'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0')) AS phone
FROM Numbers
WHERE n <= 80;

-- ============================================================================
-- STEP 6: Insert Rooms (120 rooms)
-- ============================================================================

INSERT INTO Rooms (room_number, room_type, department_id, bed_count, is_occupied, daily_rate)
SELECT
    CONCAT(
        CASE FLOOR(RAND() * 6)
            WHEN 0 THEN 'A' WHEN 1 THEN 'B' WHEN 2 THEN 'C'
            WHEN 3 THEN 'D' WHEN 4 THEN 'E' ELSE 'F'
        END,
        LPAD(FLOOR(1 + RAND() * 50), 3, '0')
    ) AS room_number,
    CASE MOD(n, 6)
        WHEN 0 THEN 'ICU' WHEN 1 THEN 'General' WHEN 2 THEN 'Private'
        WHEN 3 THEN 'Semi-Private' WHEN 4 THEN 'Operation' ELSE 'Emergency'
    END AS room_type,
    (MOD(n, 15) + 1) AS department_id,
    CASE MOD(n, 6)
        WHEN 0 THEN 1 WHEN 1 THEN 4 WHEN 2 THEN 1
        WHEN 3 THEN 2 WHEN 4 THEN 1 ELSE 2
    END AS bed_count,
    CASE WHEN RAND() < 0.65 THEN TRUE ELSE FALSE END AS is_occupied,
    CASE MOD(n, 6)
        WHEN 0 THEN ROUND(1500 + RAND() * 1000, 2)
        WHEN 1 THEN ROUND(300 + RAND() * 200, 2)
        WHEN 2 THEN ROUND(800 + RAND() * 400, 2)
        WHEN 3 THEN ROUND(500 + RAND() * 300, 2)
        WHEN 4 THEN ROUND(2000 + RAND() * 1500, 2)
        ELSE ROUND(400 + RAND() * 250, 2)
    END AS daily_rate
FROM Numbers
WHERE n <= 120;

-- ============================================================================
-- STEP 7: Insert Appointments (8,000 appointments over 2 years)
-- ============================================================================

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time, appointment_status, reason)
SELECT
    FLOOR(1 + RAND() * 2000) AS patient_id,
    FLOOR(1 + RAND() * 50) AS doctor_id,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS appointment_date,
    CONCAT(
        LPAD(FLOOR(8 + RAND() * 9), 2, '0'), ':',
        CASE FLOOR(RAND() * 4)
            WHEN 0 THEN '00' WHEN 1 THEN '15' WHEN 2 THEN '30' ELSE '45'
        END
    ) AS appointment_time,
    CASE
        WHEN RAND() < 0.72 THEN 'Completed'
        WHEN RAND() < 0.85 THEN 'No-Show'
        WHEN RAND() < 0.95 THEN 'Cancelled'
        ELSE 'Scheduled'
    END AS appointment_status,
    CASE MOD(n, 10)
        WHEN 0 THEN 'Annual Checkup' WHEN 1 THEN 'Follow-up Visit'
        WHEN 2 THEN 'Chest Pain' WHEN 3 THEN 'Headache'
        WHEN 4 THEN 'Joint Pain' WHEN 5 THEN 'Skin Rash'
        WHEN 6 THEN 'Breathing Difficulty' WHEN 7 THEN 'Stomach Pain'
        WHEN 8 THEN 'Eye Examination' WHEN 9 THEN 'Ear Infection'
    END AS reason
FROM Numbers
WHERE n <= 8000;

-- ============================================================================
-- STEP 8: Insert Admissions (3,000 admissions over 2 years)
-- ============================================================================

INSERT INTO Admissions (patient_id, doctor_id, room_id, admission_date, discharge_date, admission_reason, admission_status)
SELECT
    FLOOR(1 + RAND() * 2000) AS patient_id,
    FLOOR(1 + RAND() * 50) AS doctor_id,
    FLOOR(1 + RAND() * 120) AS room_id,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS admission_date,
    CASE
        WHEN RAND() < 0.85 THEN DATE_ADD(
            DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY),
            INTERVAL FLOOR(1 + RAND() * 14) DAY
        )
        ELSE NULL
    END AS discharge_date,
    CASE MOD(n, 10)
        WHEN 0 THEN 'Heart Attack' WHEN 1 THEN 'Stroke'
        WHEN 2 THEN 'Fracture' WHEN 3 THEN 'Pneumonia'
        WHEN 4 THEN 'Surgery Recovery' WHEN 5 THEN 'Infection'
        WHEN 6 THEN 'Diabetic Complications' WHEN 7 THEN 'Asthma Attack'
        WHEN 8 THEN 'Appendicitis' WHEN 9 THEN 'Kidney Stones'
    END AS admission_reason,
    CASE
        WHEN RAND() < 0.80 THEN 'Discharged'
        WHEN RAND() < 0.95 THEN 'Active'
        WHEN RAND() < 0.98 THEN 'Transferred'
        ELSE 'Deceased'
    END AS admission_status
FROM Numbers
WHERE n <= 3000;

-- ============================================================================
-- STEP 9: Insert Diagnoses (4,500 diagnoses)
-- ============================================================================

INSERT INTO Diagnoses (admission_id, diagnosis_code, diagnosis_name, diagnosis_date, severity, notes)
SELECT
    FLOOR(1 + RAND() * 3000) AS admission_id,
    CONCAT('ICD-', LPAD(FLOOR(1000 + RAND() * 8999), 4, '0')) AS diagnosis_code,
    CASE MOD(n, 15)
        WHEN 0 THEN 'Hypertension' WHEN 1 THEN 'Diabetes Type 2'
        WHEN 2 THEN 'Coronary Artery Disease' WHEN 3 THEN 'Pneumonia'
        WHEN 4 THEN 'Acute Myocardial Infarction' WHEN 5 THEN 'Cerebrovascular Accident'
        WHEN 6 THEN 'Fracture - Femur' WHEN 7 THEN 'Chronic Obstructive Pulmonary Disease'
        WHEN 8 THEN 'Gastroesophageal Reflux' WHEN 9 THEN 'Urinary Tract Infection'
        WHEN 10 THEN 'Anemia' WHEN 11 THEN 'Atrial Fibrillation'
        WHEN 12 THEN 'Congestive Heart Failure' WHEN 13 THEN 'Sepsis'
        WHEN 14 THEN 'Acute Appendicitis'
    END AS diagnosis_name,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS diagnosis_date,
    CASE MOD(n, 4)
        WHEN 0 THEN 'Mild' WHEN 1 THEN 'Moderate' WHEN 2 THEN 'Severe' ELSE 'Critical'
    END AS severity,
    CONCAT('Patient presenting with symptoms consistent with ', 
           CASE MOD(n, 15)
               WHEN 0 THEN 'hypertension' WHEN 1 THEN 'type 2 diabetes'
               WHEN 2 THEN 'coronary artery disease' WHEN 3 THEN 'pneumonia'
               WHEN 4 THEN 'acute MI' WHEN 5 THEN 'stroke'
               WHEN 6 THEN 'femur fracture' WHEN 7 THEN 'COPD'
               WHEN 8 THEN 'GERD' WHEN 9 THEN 'UTI'
               WHEN 10 THEN 'anemia' WHEN 11 THEN 'atrial fibrillation'
               WHEN 12 THEN 'CHF' WHEN 13 THEN 'sepsis'
               WHEN 14 THEN 'appendicitis'
           END) AS notes
FROM Numbers
WHERE n <= 4500;

-- ============================================================================
-- STEP 10: Insert Treatments (5,000 treatments)
-- ============================================================================

INSERT INTO Treatments (admission_id, doctor_id, treatment_name, treatment_category, treatment_date, cost, notes)
SELECT
    FLOOR(1 + RAND() * 3000) AS admission_id,
    FLOOR(1 + RAND() * 50) AS doctor_id,
    CASE MOD(n, 12)
        WHEN 0 THEN 'Angioplasty' WHEN 1 THEN 'Joint Replacement'
        WHEN 2 THEN 'Appendectomy' WHEN 3 THEN 'Chemotherapy Session'
        WHEN 4 THEN 'Physical Therapy' WHEN 5 THEN 'Wound Debridement'
        WHEN 6 THEN 'IV Antibiotics' WHEN 7 THEN 'Oxygen Therapy'
        WHEN 8 THEN 'Blood Transfusion' WHEN 9 THEN 'Dialysis Session'
        WHEN 10 THEN 'Endoscopy' WHEN 11 THEN 'MRI Scan'
    END AS treatment_name,
    CASE MOD(n, 6)
        WHEN 0 THEN 'Surgical' WHEN 1 THEN 'Therapeutic'
        WHEN 2 THEN 'Diagnostic' WHEN 3 THEN 'Medication'
        WHEN 4 THEN 'Rehabilitation' ELSE 'Emergency'
    END AS treatment_category,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS treatment_date,
    CASE MOD(n, 12)
        WHEN 0 THEN ROUND(5000 + RAND() * 10000, 2)
        WHEN 1 THEN ROUND(15000 + RAND() * 25000, 2)
        WHEN 2 THEN ROUND(3000 + RAND() * 5000, 2)
        WHEN 3 THEN ROUND(2000 + RAND() * 8000, 2)
        WHEN 4 THEN ROUND(200 + RAND() * 500, 2)
        WHEN 5 THEN ROUND(500 + RAND() * 1500, 2)
        WHEN 6 THEN ROUND(300 + RAND() * 800, 2)
        WHEN 7 THEN ROUND(200 + RAND() * 600, 2)
        WHEN 8 THEN ROUND(1000 + RAND() * 3000, 2)
        WHEN 9 THEN ROUND(400 + RAND() * 1000, 2)
        WHEN 10 THEN ROUND(1500 + RAND() * 3000, 2)
        ELSE ROUND(2000 + RAND() * 5000, 2)
    END AS cost,
    CONCAT('Treatment administered on scheduled date') AS notes
FROM Numbers
WHERE n <= 5000;

-- ============================================================================
-- STEP 11: Insert Prescriptions (6,000 prescriptions)
-- ============================================================================

INSERT INTO Prescriptions (admission_id, doctor_id, medication_name, dosage, frequency, start_date, end_date, cost)
SELECT
    FLOOR(1 + RAND() * 3000) AS admission_id,
    FLOOR(1 + RAND() * 50) AS doctor_id,
    CASE MOD(n, 15)
        WHEN 0 THEN 'Aspirin' WHEN 1 THEN 'Metformin' WHEN 2 THEN 'Lisinopril'
        WHEN 3 THEN 'Amoxicillin' WHEN 4 THEN 'Omeprazole' WHEN 5 THEN 'Atorvastatin'
        WHEN 6 THEN 'Metoprolol' WHEN 7 THEN 'Amlodipine' WHEN 8 THEN 'Losartan'
        WHEN 9 THEN 'Gabapentin' WHEN 10 THEN 'Pantoprazole' WHEN 11 THEN 'Levothyroxine'
        WHEN 12 THEN 'Albuterol' WHEN 13 THEN 'Prednisone' WHEN 14 THEN 'Warfarin'
    END AS medication_name,
    CASE MOD(n, 4)
        WHEN 0 THEN '10mg' WHEN 1 THEN '25mg' WHEN 2 THEN '50mg' ELSE '100mg'
    END AS dosage,
    CASE MOD(n, 3)
        WHEN 0 THEN 'Once daily' WHEN 1 THEN 'Twice daily' ELSE 'Three times daily'
    END AS frequency,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS start_date,
    DATE_ADD(DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY), INTERVAL FLOOR(7 + RAND() * 30) DAY) AS end_date,
    ROUND(5 + RAND() * 200, 2) AS cost
FROM Numbers
WHERE n <= 6000;

-- ============================================================================
-- STEP 12: Insert Medical_Tests (4,000 tests)
-- ============================================================================

INSERT INTO Medical_Tests (admission_id, doctor_id, test_name, test_date, result, cost, status)
SELECT
    FLOOR(1 + RAND() * 3000) AS admission_id,
    FLOOR(1 + RAND() * 50) AS doctor_id,
    CASE MOD(n, 10)
        WHEN 0 THEN 'Complete Blood Count' WHEN 1 THEN 'Lipid Panel'
        WHEN 2 THEN 'ECG' WHEN 3 THEN 'Chest X-Ray'
        WHEN 4 THEN 'CT Scan' WHEN 5 THEN 'MRI Brain'
        WHEN 6 THEN 'Blood Glucose' WHEN 7 THEN 'Liver Function Test'
        WHEN 8 THEN 'Kidney Function Test' WHEN 9 THEN 'Thyroid Panel'
    END AS test_name,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS test_date,
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'Normal' WHEN 1 THEN 'Abnormal - Requires Follow-up' ELSE 'Critical - Immediate Action'
    END AS result,
    CASE MOD(n, 10)
        WHEN 0 THEN ROUND(50 + RAND() * 100, 2)
        WHEN 1 THEN ROUND(80 + RAND() * 150, 2)
        WHEN 2 THEN ROUND(100 + RAND() * 200, 2)
        WHEN 3 THEN ROUND(150 + RAND() * 300, 2)
        WHEN 4 THEN ROUND(500 + RAND() * 1000, 2)
        WHEN 5 THEN ROUND(800 + RAND() * 1500, 2)
        WHEN 6 THEN ROUND(30 + RAND() * 70, 2)
        WHEN 7 THEN ROUND(100 + RAND() * 250, 2)
        WHEN 8 THEN ROUND(80 + RAND() * 200, 2)
        ELSE ROUND(60 + RAND() * 120, 2)
    END AS cost,
    CASE
        WHEN RAND() < 0.85 THEN 'Completed'
        WHEN RAND() < 0.95 THEN 'Pending'
        ELSE 'Cancelled'
    END AS status
FROM Numbers
WHERE n <= 4000;

-- ============================================================================
-- STEP 13: Insert Insurance (1,800 insurance records)
-- ============================================================================

INSERT INTO Insurance (patient_id, provider_name, policy_number, coverage_percentage, max_coverage, start_date, end_date)
SELECT
    FLOOR(1 + RAND() * 2000) AS patient_id,
    CASE MOD(n, 6)
        WHEN 0 THEN 'Blue Cross Blue Shield' WHEN 1 THEN 'Aetna'
        WHEN 2 THEN 'UnitedHealthcare' WHEN 3 THEN 'Cigna'
        WHEN 4 THEN 'Humana' ELSE 'Kaiser Permanente'
    END AS provider_name,
    CONCAT('POL-', LPAD(FLOOR(100000 + RAND() * 900000), 6, '0')) AS policy_number,
    CASE MOD(n, 4)
        WHEN 0 THEN 70.00 WHEN 1 THEN 80.00 WHEN 2 THEN 90.00 ELSE 100.00
    END AS coverage_percentage,
    CASE MOD(n, 4)
        WHEN 0 THEN 100000.00 WHEN 1 THEN 250000.00 WHEN 2 THEN 500000.00 ELSE 1000000.00
    END AS max_coverage,
    DATE_ADD('2022-01-01', INTERVAL FLOOR(RAND() * 1000) DAY) AS start_date,
    DATE_ADD(DATE_ADD('2022-01-01', INTERVAL FLOOR(RAND() * 1000) DAY), INTERVAL 365 DAY) AS end_date
FROM Numbers
WHERE n <= 1800;

-- ============================================================================
-- STEP 14: Insert Bills (3,500 bills)
-- ============================================================================

INSERT INTO Bills (admission_id, patient_id, bill_date, total_amount, insurance_covered, patient_responsibility, bill_status, due_date)
SELECT
    FLOOR(1 + RAND() * 3000) AS admission_id,
    FLOOR(1 + RAND() * 2000) AS patient_id,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS bill_date,
    total_amt AS total_amount,
    ROUND(total_amt * coverage_pct / 100, 2) AS insurance_covered,
    ROUND(total_amt * (1 - coverage_pct / 100), 2) AS patient_responsibility,
    CASE
        WHEN RAND() < 0.65 THEN 'Paid'
        WHEN RAND() < 0.85 THEN 'Partially Paid'
        WHEN RAND() < 0.95 THEN 'Pending'
        ELSE 'Overdue'
    END AS bill_status,
    DATE_ADD(DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY), INTERVAL 30 DAY) AS due_date
FROM (
    SELECT 
        n,
        ROUND(500 + RAND() * 49500, 2) AS total_amt,
        CASE MOD(n, 4)
            WHEN 0 THEN 70.00 WHEN 1 THEN 80.00 WHEN 2 THEN 90.00 ELSE 100.00
        END AS coverage_pct
    FROM Numbers
    WHERE n <= 3500
) AS bill_data;

-- ============================================================================
-- STEP 15: Insert Payments (5,000 payments)
-- ============================================================================

INSERT INTO Payments (bill_id, patient_id, payment_date, payment_amount, payment_method, transaction_reference)
SELECT
    FLOOR(1 + RAND() * 3500) AS bill_id,
    FLOOR(1 + RAND() * 2000) AS patient_id,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY) AS payment_date,
    ROUND(100 + RAND() * 20000, 2) AS payment_amount,
    CASE MOD(n, 6)
        WHEN 0 THEN 'Cash' WHEN 1 THEN 'Credit Card' WHEN 2 THEN 'Debit Card'
        WHEN 3 THEN 'Insurance' WHEN 4 THEN 'Bank Transfer' ELSE 'Check'
    END AS payment_method,
    CONCAT('TXN-', LPAD(FLOOR(1000000 + RAND() * 9000000), 7, '0')) AS transaction_reference
FROM Numbers
WHERE n <= 5000;

-- ============================================================================
-- DATA GENERATION COMPLETE
-- ============================================================================
-- Summary:
-- - 15 departments
-- - 50 doctors
-- - 2,000 patients
-- - 80 nurses
-- - 120 rooms
-- - 8,000 appointments (2 years)
-- - 3,000 admissions (2 years)
-- - 4,500 diagnoses
-- - 5,000 treatments
-- - 6,000 prescriptions
-- - 4,000 medical tests
-- - 1,800 insurance records
-- - 3,500 bills
-- - 5,000 payments
--
-- Next Step: Run 03_patient_analysis.sql to begin analysis
-- ============================================================================
