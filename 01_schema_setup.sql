-- ============================================================================
-- 01_schema_setup.sql
-- Hospital Patient Analytics Project
-- ============================================================================
-- Purpose: Create the hospital database and all relational tables
-- Database: MySQL 8.0+ (also compatible with PostgreSQL/SQL Server)
-- ============================================================================

-- ============================================================================
-- DATABASE CREATION
-- ============================================================================

DROP DATABASE IF EXISTS hospital_db;

CREATE DATABASE hospital_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hospital_db;

-- ============================================================================
-- TABLE 1: Departments
-- ============================================================================
-- Stores hospital departments and their specialties.
-- Each department has a name, location, and a head doctor.
-- ============================================================================

CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    head_doctor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 2: Doctors
-- ============================================================================
-- Stores physician records including name, specialization, and salary.
-- Each doctor belongs to one department.
-- ============================================================================

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (salary > 0)
);

-- Add foreign key for Departments.head_doctor_id after Doctors table is created
ALTER TABLE Departments
    ADD FOREIGN KEY (head_doctor_id) REFERENCES Doctors(doctor_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- ============================================================================
-- TABLE 3: Patients
-- ============================================================================
-- Stores patient demographics: name, date of birth, gender, contact info.
-- DOB is stored so we can calculate age dynamically.
-- ============================================================================

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    registration_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE 4: Nurses
-- ============================================================================
-- Stores nursing staff records including their assigned department.
-- ============================================================================

CREATE TABLE Nurses (
    nurse_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    shift ENUM('Morning', 'Afternoon', 'Night') NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (salary > 0)
);

-- ============================================================================
-- TABLE 5: Rooms
-- ============================================================================
-- Stores room inventory and bed management information.
-- Each room belongs to a department and has a type (ICU, General, etc.).
-- ============================================================================

CREATE TABLE Rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type ENUM('ICU', 'General', 'Private', 'Semi-Private', 'Operation', 'Emergency') NOT NULL,
    department_id INT NOT NULL,
    bed_count INT NOT NULL DEFAULT 1,
    is_occupied BOOLEAN DEFAULT FALSE,
    daily_rate DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (bed_count > 0),
    CHECK (daily_rate > 0)
);

-- ============================================================================
-- TABLE 6: Appointments
-- ============================================================================
-- Stores outpatient scheduling and tracking.
-- Links patients to doctors with a scheduled date and time.
-- ============================================================================

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    appointment_status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') NOT NULL DEFAULT 'Scheduled',
    reason VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================================
-- TABLE 7: Admissions
-- ============================================================================
-- Stores inpatient admission records.
-- Tracks when patients are admitted, discharged, and which room they occupy.
-- ============================================================================

CREATE TABLE Admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_reason TEXT,
    admission_status ENUM('Active', 'Discharged', 'Transferred', 'Deceased') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================================
-- TABLE 8: Diagnoses
-- ============================================================================
-- Stores medical diagnoses linked to admissions.
-- Each diagnosis has an ICD code and description.
-- ============================================================================

CREATE TABLE Diagnoses (
    diagnosis_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id INT NOT NULL,
    diagnosis_code VARCHAR(20) NOT NULL,
    diagnosis_name VARCHAR(200) NOT NULL,
    diagnosis_date DATE NOT NULL,
    severity ENUM('Mild', 'Moderate', 'Severe', 'Critical') NOT NULL DEFAULT 'Moderate',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================================
-- TABLE 9: Treatments
-- ============================================================================
-- Stores medical procedures and interventions.
-- Each treatment is linked to an admission and performed by a doctor.
-- ============================================================================

CREATE TABLE Treatments (
    treatment_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id INT NOT NULL,
    doctor_id INT NOT NULL,
    treatment_name VARCHAR(200) NOT NULL,
    treatment_category VARCHAR(100) NOT NULL,
    treatment_date DATE NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (cost > 0)
);

-- ============================================================================
-- TABLE 10: Prescriptions
-- ============================================================================
-- Stores medication prescriptions linked to admissions.
-- ============================================================================

CREATE TABLE Prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (cost >= 0)
);

-- ============================================================================
-- TABLE 11: Medical_Tests
-- ============================================================================
-- Stores lab and diagnostic test results.
-- ============================================================================

CREATE TABLE Medical_Tests (
    test_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id INT NOT NULL,
    doctor_id INT NOT NULL,
    test_name VARCHAR(200) NOT NULL,
    test_date DATE NOT NULL,
    result TEXT,
    cost DECIMAL(10, 2) NOT NULL,
    status ENUM('Pending', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (cost > 0)
);

-- ============================================================================
-- TABLE 12: Insurance
-- ============================================================================
-- Stores patient insurance coverage information.
-- Links patients to their insurance providers with coverage details.
-- ============================================================================

CREATE TABLE Insurance (
    insurance_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    policy_number VARCHAR(50) NOT NULL,
    coverage_percentage DECIMAL(5, 2) NOT NULL,
    max_coverage DECIMAL(12, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (coverage_percentage > 0 AND coverage_percentage <= 100),
    CHECK (max_coverage > 0)
);

-- ============================================================================
-- TABLE 13: Bills
-- ============================================================================
-- Stores patient billing and charges.
-- Each bill is linked to an admission and includes various charges.
-- ============================================================================

CREATE TABLE Bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id INT NOT NULL,
    patient_id INT NOT NULL,
    bill_date DATE NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    insurance_covered DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    patient_responsibility DECIMAL(12, 2) NOT NULL,
    bill_status ENUM('Pending', 'Paid', 'Partially Paid', 'Overdue', 'Cancelled') NOT NULL DEFAULT 'Pending',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (total_amount > 0),
    CHECK (insurance_covered >= 0),
    CHECK (patient_responsibility >= 0)
);

-- ============================================================================
-- TABLE 14: Payments
-- ============================================================================
-- Stores payment transactions and collections.
-- Each payment is linked to a bill.
-- ============================================================================

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT NOT NULL,
    patient_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Bank Transfer', 'Check') NOT NULL,
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES Bills(bill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (payment_amount > 0)
);

-- ============================================================================
-- SCHEMA COMPLETE
-- ============================================================================
-- Relationships:
--
-- Departments (1) ──────< (M) Doctors
-- Departments (1) ──────< (M) Nurses
-- Departments (1) ──────< (M) Rooms
-- Doctors (1) ───────────< (M) Appointments
-- Patients (1) ──────────< (M) Appointments
-- Patients (1) ──────────< (M) Admissions
-- Patients (1) ──────────< (M) Insurance
-- Patients (1) ──────────< (M) Bills
-- Patients (1) ──────────< (M) Payments
-- Rooms (1) ─────────────< (M) Admissions
-- Admissions (1) ────────< (M) Diagnoses
-- Admissions (1) ────────< (M) Treatments
-- Admissions (1) ────────< (M) Prescriptions
-- Admissions (1) ────────< (M) Medical_Tests
-- Admissions (1) ────────< (M) Bills
-- Bills (1) ─────────────< (M) Payments
--
-- Next Step: Run 02_data_generation.sql to populate with data
-- ============================================================================
