# Bank Loan Customer Analysis

An end-to-end finance analytics project that analyzes **39,717 bank-loan records** using **Excel, MySQL, and Power BI**. The project combines two finance tables, calculates five groups of business KPIs, and presents loan performance, customer verification, repayment, risk, and portfolio trends in an interactive dashboard.

## Project Objective

The objective is to help a lending business understand:

- How loan amounts changed from year to year.
- How revolving balances differ across loan grades and sub-grades.
- Whether verified customers generate higher payments.
- How loan status varies across states and issue months.
- How home ownership and last-payment timing relate to payment activity.

## Tools Used

- **Microsoft Excel:** Source inspection, KPI validation, and dashboard preparation
- **MySQL:** Table joins, data-quality checks, aggregation, and KPI analysis
- **Power BI:** Interactive visualization and business reporting
- **GitHub:** Project documentation and version control

## Dataset Structure

The project uses two datasets containing **39,717 records each**. They are joined using the common `id` column. Validation found 39,717 matched unique loan IDs, with no duplicate or unmatched IDs.

### Finance_1

| Column | Purpose |
| --- | --- |
| `id` | Unique loan identifier and join key |
| `issue_d` | Loan issue month/date |
| `loan_amnt` | Approved loan amount |
| `grade` | Main loan-risk grade |
| `sub_grade` | Detailed loan-risk grade |
| `verification_status` | Income verification category |
| `addr_state` | Borrower's state |
| `loan_status` | Current outcome/status of the loan |
| `home_ownership` | Borrower's home-ownership category |

### Finance_2

| Column | Purpose |
| --- | --- |
| `id` | Unique loan identifier and join key |
| `revol_bal` | Revolving credit balance |
| `total_pymnt` | Total payment received |
| `last_pymnt_d` | Last payment month/date |
| `last_pymnt_amnt` | Most recent payment amount |

## Relationship

```text
Finance_1.id  ─────  Finance_2.id
       one-to-one matched loan relationship
```

## KPI Analysis

### 1. Year-wise Loan Amount

- Total loan amount
- Number of loans
- Average loan amount
- Year-over-year portfolio trend

### 2. Revolving Balance by Grade and Sub-grade

- Total revolving balance
- Average revolving balance
- Number of customers in each risk category

### 3. Payments by Verification Status

- Total payments from Verified customers
- Total payments from Source Verified customers
- Total payments from Not Verified customers
- Combined verified-versus-not-verified comparison

### 4. Loan Status by State and Issue Month

- Loan counts by state and status
- Monthly trend for Fully Paid, Charged Off, and Current loans
- Geographical and time-based risk comparison

### 5. Home Ownership and Last Payment Analysis

- Loan count by home-ownership category and last-payment month
- Total last-payment amount
- Average last-payment amount
- Missing last-payment-date validation

## Main Results

| Metric | Result |
| --- | ---: |
| Total matched loans | 39,717 |
| Total funded loan amount | Approximately $445.6 million |
| Highest yearly loan amount | 2011: approximately $260.5 million |
| Total recorded payments | Approximately $482.7 million |
| Fully Paid | 32,950 loans (82.96%) |
| Charged Off | 5,627 loans (14.17%) |
| Current | 1,140 loans (2.87%) |
| Verified + Source Verified payments | Approximately $329.2 million |
| Not Verified payments | Approximately $153.5 million |
| Highest average revolving balance | Grade G: approximately $20,452 |
| Missing last-payment dates | 71 records |

## Dashboard Visuals

1. **Column chart:** Year-wise loan amount
2. **Column chart:** Revolving balance by grade and sub-grade
3. **Column chart:** Total payments by verification status
4. **Column chart:** State-wise loan-status distribution
5. **Line chart:** Monthly loan-status trend
6. **Line chart:** Home ownership versus last-payment month

## Key Insights

- The portfolio contained approximately **$445.6 million** in loan value, with 2011 contributing the highest annual amount.
- Around **83% of loans were fully paid**, showing a strong overall repayment outcome.
- The **14.17% charged-off share** represents the primary credit-risk concern.
- Verified and source-verified borrowers generated substantially more recorded payments than not-verified borrowers.
- Grade G had the highest average revolving balance, indicating higher credit utilization among the riskiest borrowers.
- Seventy-one missing last-payment dates were excluded from date-based payment analysis to prevent misleading results.

## Business Recommendations

- Monitor high-risk grades and charged-off loans more closely.
- Strengthen affordability and income-verification checks for risky applications.
- Investigate states and issue months with unusually high charged-off counts.
- Use repayment history and revolving balance together when reviewing credit risk.
- Track missing payment dates as a data-quality KPI.

## Repository Contents

```text
bank-loan-customer-analysis/
├── README.md
├── Bank_Loan_Customer_Analysis.sql
├── Bank_Loan_Customer_Analysis.xlsx
├── Bank_Loan_Dashboard.pbix
└── dashboard-screenshot.png
```

## How to Run the SQL Analysis

1. Import both worksheets or CSV files into MySQL as `Finance_1` and `Finance_2`.
2. Confirm that their shared key is named `id`.
3. Select the database containing both tables.
4. Open `Bank_Loan_Customer_Analysis.sql` in MySQL Workbench.
5. Run the validation section first.
6. Run the view and KPI queries.
7. Compare the outputs with the Excel or Power BI dashboard.

## Important Notes

- The SQL assumes dates use a month-year format such as `Dec-11`. Adjust `STR_TO_DATE()` if your imported date format is different.
- The two datasets must be joined on `id`; adding monetary columns without joining correctly can duplicate values.
- Missing last-payment dates are retained for general loan analysis but excluded from month-based payment charts.

## Author

**Tarun Hari Krishna Kollipara**  
Aspiring Data Analyst

---

If you find this project useful, consider starring the repository.
