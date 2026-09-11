# Hospital Patient Analytics - SQL Portfolio Project

## Project Overview

This project analyzes hospital operations, patient demographics, and revenue cycles using SQL. The goal is to identify trends in doctor performance, patient no-shows, treatment costs, and billing efficiency to provide actionable business insights for hospital management.

The entire analysis is performed using SQL only - no Python, Excel, Power BI, or other tools.

## Business Problem

Hospitals generate vast amounts of data across departments, doctors, patients, treatments, and billing. This project transforms raw hospital data into actionable insights by answering critical questions:

- Which departments generate the most revenue?
- Which doctors have the highest patient load?
- What is the financial impact of no-shows?
- Which treatments are the most cost-intensive?
- Where should the hospital focus to improve efficiency?

## Database Schema

The database contains 14 relational tables:

| Table | Records | Description |
|-------|---------|-------------|
| Departments | 15 | Hospital departments and specialties |
| Doctors | 50 | Physician records and specializations |
| Patients | 2,000 | Patient demographics and contact info |
| Nurses | 80 | Nursing staff records |
| Rooms | 120 | Room inventory and bed management |
| Appointments | 8,000 | Outpatient scheduling (2 years) |
| Admissions | 3,000 | Inpatient admission records |
| Diagnoses | 4,500 | Medical diagnoses and disease tracking |
| Treatments | 5,000 | Medical procedures and interventions |
| Prescriptions | 6,000 | Medication prescriptions |
| Medical_Tests | 4,000 | Lab and diagnostic tests |
| Insurance | 1,800 | Patient insurance coverage |
| Bills | 3,500 | Patient billing and charges |
| Payments | 5,000 | Payment transactions and collections |

## SQL Skills Demonstrated

### Core Skills (Required)
- SELECT, WHERE, ORDER BY
- GROUP BY, HAVING
- SUM, COUNT, AVG, MIN, MAX
- Simple Subqueries
- CASE WHEN (Conditional Logic)
- INNER JOIN, LEFT JOIN

### Additional Skills
- Date Functions (YEAR, MONTH, DATE_FORMAT, DATEDIFF, TIMESTAMPDIFF)
- Self Join (for readmission analysis)
- Percentage calculations
- NULL handling (COALESCE, NULLIF)
- Conditional aggregation (SUM with CASE WHEN)

## Query Coverage

### Patient & Appointment Analysis (6 queries)
1. Total appointments per department
2. Monthly appointment trends
3. No-show rate calculation by department
4. Patient demographics (age, gender) segmentation
5. Average wait time by department
6. Appointment status summary

### Doctor Performance Analysis (5 queries)
7. Total patients treated per doctor
8. Revenue generated per doctor
9. Rank doctors by patient volume within department
10. Average length of stay per doctor's patients
11. Workload distribution across specialties

### Revenue & Billing Analysis (5 queries)
12. Total revenue generated (bills, insurance, payments)
13. Monthly revenue and growth trends
14. Average bill amount per patient
15. Outstanding revenue (bills vs. payments)
16. Insurance coverage vs. patient responsibility

### Treatment & Resource Analysis (6 queries)
17. Top treatments by frequency and cost
18. Category-wise treatment costs
19. Average length of stay per department
20. Bed occupancy rates
21. Readmission rate (Self Join)
22. Diagnostic test volume and cost

### Business Insights (8 queries)
23. Revenue by department
24. Highest patient load doctors
25. Financial impact of no-shows
26. Cost-intensive treatments
27. Efficiency improvement areas
28. Patient demographics summary
29. Insurance provider performance
30. Monthly revenue growth rate

## How to Run

1. Run `01_schema_setup.sql` to create the database and tables
2. Run `02_data_generation.sql` to populate with realistic mock data
3. Run analysis files `03-07` in order

**Note:** This project uses MySQL syntax. Minor adjustments may be needed for PostgreSQL or SQL Server.

## Key Business Insights

| Insight | Finding | Recommendation |
|---------|---------|----------------|
| Revenue Drivers | Cardiology and Oncology generate highest revenue | Continue investment in these departments |
| Doctor Workload | Some doctors handle 3x average patient load | Add support staff or redistribute patients |
| No-Show Impact | Emergency department has highest no-show rate | Implement automated reminder systems |
| Cost Intensity | Surgical treatments cost 5x average | Review efficiency and pricing |
| Bed Occupancy | ICU rooms at 90%+ occupancy | Plan capacity expansion |
| Readmissions | 15% of patients readmitted within 30 days | Improve discharge planning |

## Project Workflow

```
Database Setup → Data Generation → Patient Analysis → Doctor Performance → Revenue Analysis → Treatment Analysis → Business Insights
      ↓                ↓                ↓                  ↓                  ↓                 ↓                  ↓
01_schema.sql    02_data.sql    03_patient.sql    04_doctor.sql    05_revenue.sql    06_treatment.sql    07_insights.sql
```

## Portfolio Description

This project demonstrates SQL skills through comprehensive hospital operations analysis. I designed a 14-table database schema, generated realistic mock data spanning 2 years, and performed in-depth analysis covering patient demographics, doctor performance, revenue cycles, and treatment efficiency. The analysis uses subqueries, joins, aggregate functions, and conditional logic to provide actionable business insights for hospital management decision-making.

---

**Project by:** Khushi Goel
**Date:** 10/09/26
**Database:** MySQL 8.0+
