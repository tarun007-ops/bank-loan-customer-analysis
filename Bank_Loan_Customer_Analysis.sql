/*
    Project: Bank Loan Customer Analysis
    Database: MySQL 8+
    Tables: Finance_1 and Finance_2
    Join key: id

    Before running:
    1. Import both datasets into the same MySQL database.
    2. Select that database in MySQL Workbench.
    3. Confirm the table and column names match this script.
*/

-- Replace the database name below with your database name if necessary.
-- USE bank_loan_analysis;

-- ================================================================
-- 1. DATASET VALIDATION
-- ================================================================

-- Count rows and unique IDs in Finance_1.
SELECT
    COUNT(*) AS finance_1_rows,
    COUNT(DISTINCT id) AS finance_1_unique_ids
FROM Finance_1;

-- Count rows and unique IDs in Finance_2.
SELECT
    COUNT(*) AS finance_2_rows,
    COUNT(DISTINCT id) AS finance_2_unique_ids
FROM Finance_2;

-- Check duplicate IDs in Finance_1. Expected result: no rows.
SELECT id, COUNT(*) AS duplicate_count
FROM Finance_1
GROUP BY id
HAVING COUNT(*) > 1;

-- Check duplicate IDs in Finance_2. Expected result: no rows.
SELECT id, COUNT(*) AS duplicate_count
FROM Finance_2
GROUP BY id
HAVING COUNT(*) > 1;

-- Confirm the number of matched records. Expected result: 39,717.
SELECT COUNT(*) AS matched_loans
FROM Finance_1 AS f1
INNER JOIN Finance_2 AS f2
    ON f1.id = f2.id;

-- Check for IDs in Finance_1 without a match in Finance_2.
SELECT COUNT(*) AS unmatched_finance_1_ids
FROM Finance_1 AS f1
LEFT JOIN Finance_2 AS f2
    ON f1.id = f2.id
WHERE f2.id IS NULL;

-- Check for IDs in Finance_2 without a match in Finance_1.
SELECT COUNT(*) AS unmatched_finance_2_ids
FROM Finance_2 AS f2
LEFT JOIN Finance_1 AS f1
    ON f2.id = f1.id
WHERE f1.id IS NULL;

-- Count missing last-payment dates.
SELECT COUNT(*) AS missing_last_payment_dates
FROM Finance_2
WHERE last_pymnt_d IS NULL
   OR TRIM(last_pymnt_d) = '';

-- ================================================================
-- 2. CREATE A REUSABLE JOINED VIEW
-- ================================================================

DROP VIEW IF EXISTS bank_loan_customer_details;

CREATE VIEW bank_loan_customer_details AS
SELECT
    f1.id,
    f1.issue_d,
    f1.loan_amnt,
    f1.grade,
    f1.sub_grade,
    f1.verification_status,
    f1.addr_state,
    f1.loan_status,
    f1.home_ownership,
    f2.revol_bal,
    f2.total_pymnt,
    f2.last_pymnt_d,
    f2.last_pymnt_amnt
FROM Finance_1 AS f1
INNER JOIN Finance_2 AS f2
    ON f1.id = f2.id;

-- Verify the view.
SELECT COUNT(*) AS joined_view_rows
FROM bank_loan_customer_details;

-- ================================================================
-- 3. EXECUTIVE SUMMARY
-- ================================================================

SELECT
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amnt), 2) AS total_loan_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
    ROUND(SUM(total_pymnt), 2) AS total_payments,
    ROUND(AVG(total_pymnt), 2) AS average_payment,
    ROUND(SUM(revol_bal), 2) AS total_revolving_balance
FROM bank_loan_customer_details;

-- Overall loan-status distribution.
SELECT
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_loans,
    ROUND(SUM(loan_amnt), 2) AS total_loan_amount,
    ROUND(SUM(total_pymnt), 2) AS total_payments
FROM bank_loan_customer_details
GROUP BY loan_status
ORDER BY loan_count DESC;

-- ================================================================
-- 4. KPI 1: YEAR-WISE LOAN AMOUNT STATISTICS
-- ================================================================

SELECT
    YEAR(STR_TO_DATE(issue_d, '%b-%y')) AS issue_year,
    COUNT(*) AS loan_count,
    ROUND(SUM(loan_amnt), 2) AS total_loan_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
    ROUND(MIN(loan_amnt), 2) AS minimum_loan_amount,
    ROUND(MAX(loan_amnt), 2) AS maximum_loan_amount
FROM bank_loan_customer_details
GROUP BY YEAR(STR_TO_DATE(issue_d, '%b-%y'))
ORDER BY issue_year;

-- ================================================================
-- 5. KPI 2: REVOLVING BALANCE BY GRADE AND SUB-GRADE
-- ================================================================

SELECT
    grade,
    COUNT(*) AS loan_count,
    ROUND(SUM(revol_bal), 2) AS total_revolving_balance,
    ROUND(AVG(revol_bal), 2) AS average_revolving_balance
FROM bank_loan_customer_details
GROUP BY grade
ORDER BY grade;

SELECT
    grade,
    sub_grade,
    COUNT(*) AS loan_count,
    ROUND(SUM(revol_bal), 2) AS total_revolving_balance,
    ROUND(AVG(revol_bal), 2) AS average_revolving_balance
FROM bank_loan_customer_details
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- Rank grades by average revolving balance.
SELECT
    grade,
    ROUND(AVG(revol_bal), 2) AS average_revolving_balance,
    DENSE_RANK() OVER (ORDER BY AVG(revol_bal) DESC) AS balance_rank
FROM bank_loan_customer_details
GROUP BY grade
ORDER BY balance_rank;

-- ================================================================
-- 6. KPI 3: TOTAL PAYMENTS BY VERIFICATION STATUS
-- ================================================================

SELECT
    verification_status,
    COUNT(*) AS loan_count,
    ROUND(SUM(total_pymnt), 2) AS total_payments,
    ROUND(AVG(total_pymnt), 2) AS average_payment
FROM bank_loan_customer_details
GROUP BY verification_status
ORDER BY total_payments DESC;

-- Combine Verified and Source Verified into one business group.
SELECT
    CASE
        WHEN verification_status IN ('Verified', 'Source Verified')
            THEN 'Verified / Source Verified'
        ELSE 'Not Verified'
    END AS verification_group,
    COUNT(*) AS loan_count,
    ROUND(SUM(total_pymnt), 2) AS total_payments,
    ROUND(AVG(total_pymnt), 2) AS average_payment
FROM bank_loan_customer_details
GROUP BY verification_group
ORDER BY total_payments DESC;

-- ================================================================
-- 7. KPI 4: LOAN STATUS BY STATE AND ISSUE MONTH
-- ================================================================

-- State-wise loan-status analysis.
SELECT
    addr_state,
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(SUM(loan_amnt), 2) AS total_loan_amount,
    ROUND(SUM(total_pymnt), 2) AS total_payments
FROM bank_loan_customer_details
GROUP BY addr_state, loan_status
ORDER BY addr_state, loan_count DESC;

-- Month-wise loan-status trend.
SELECT
    STR_TO_DATE(issue_d, '%b-%y') AS issue_month,
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(SUM(loan_amnt), 2) AS total_loan_amount
FROM bank_loan_customer_details
GROUP BY STR_TO_DATE(issue_d, '%b-%y'), loan_status
ORDER BY issue_month, loan_status;

-- Optional Power BI-friendly monthly status table.
SELECT
    STR_TO_DATE(issue_d, '%b-%y') AS issue_month,
    SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS fully_paid,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off,
    SUM(CASE WHEN loan_status = 'Current' THEN 1 ELSE 0 END) AS current_loans,
    COUNT(*) AS total_loans
FROM bank_loan_customer_details
GROUP BY STR_TO_DATE(issue_d, '%b-%y')
ORDER BY issue_month;

-- ================================================================
-- 8. KPI 5: HOME OWNERSHIP AND LAST-PAYMENT ANALYSIS
-- ================================================================

-- Excludes missing payment dates only from date-based analysis.
SELECT
    home_ownership,
    STR_TO_DATE(last_pymnt_d, '%b-%y') AS last_payment_month,
    COUNT(*) AS loan_count,
    ROUND(SUM(last_pymnt_amnt), 2) AS total_last_payment_amount,
    ROUND(AVG(last_pymnt_amnt), 2) AS average_last_payment_amount
FROM bank_loan_customer_details
WHERE last_pymnt_d IS NOT NULL
  AND TRIM(last_pymnt_d) <> ''
GROUP BY home_ownership, STR_TO_DATE(last_pymnt_d, '%b-%y')
ORDER BY last_payment_month, home_ownership;

-- Overall home-ownership comparison.
SELECT
    home_ownership,
    COUNT(*) AS loan_count,
    ROUND(SUM(last_pymnt_amnt), 2) AS total_last_payment_amount,
    ROUND(AVG(last_pymnt_amnt), 2) AS average_last_payment_amount,
    ROUND(SUM(total_pymnt), 2) AS total_payments
FROM bank_loan_customer_details
GROUP BY home_ownership
ORDER BY total_payments DESC;

-- ================================================================
-- 9. EXTRA RISK INSIGHTS
-- ================================================================

-- Charged-off rate by grade.
SELECT
    grade,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS charged_off_rate_pct
FROM bank_loan_customer_details
GROUP BY grade
ORDER BY charged_off_rate_pct DESC;

-- Top states by total loan amount and charged-off count.
SELECT
    addr_state,
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amnt), 2) AS total_loan_amount,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans
FROM bank_loan_customer_details
GROUP BY addr_state
ORDER BY total_loan_amount DESC;

-- End of project analysis.
