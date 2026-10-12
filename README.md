# A/B Testing & Customer Targeting Analysis

## Overview

This project analyzes the Hillstrom email marketing experiment to evaluate the effectiveness of two email campaigns and explore opportunities for customer targeting.

Using SQL and Python, I validated the experimental design, estimated treatment effects on revenue and conversion, and investigated whether campaign effectiveness varied across customer purchase-history segments.

### Business Questions

1. Do email campaigns increase customer spending and purchase conversion?
2. Which email campaign generates greater incremental revenue?
3. Does campaign effectiveness vary by customers' previous merchandise purchase history?
4. How can these findings inform future email marketing decisions?

## Dataset & Experiment Design

**Dataset Source:** [Kevin Hillstrom — MineThatData E-Mail Analytics and Data Mining Challenge (2008)](https://blog.minethatdata.com/2008/03/minethatdata-e-mail-analytics-and-data.html)

**CSV Download:** [Public dataset copy on GitHub](https://github.com/W-Tran/uplift-modelling/blob/master/data/hillstrom/Kevin_Hillstrom_MineThatData_E-MailAnalytics_DataMiningChallenge_2008.03.20.csv)

The analysis uses the Hillstrom (2008) email marketing dataset, containing 64,000 customers randomly assigned to three experimental groups.

| Experimental Group | Customers | Description |
|---|---:|---|
| Men's Email | 21,307 | Received an email promoting men's merchandise |
| Women's Email | 21,387 | Received an email promoting women's merchandise |
| Control | 21,306 | Received no promotional email |

**Primary outcome:** Revenue per randomized customer (`spend`), including customers with zero spending.

**Secondary outcome:** Purchase conversion rate (`conversion`).

**Customer targeting variables:** Historical men's and women's merchandise purchase indicators (`mens`, `womens`).

These purchase indicators describe previous shopping behavior, not customer gender.

## Key Findings

### 1. Both Email Campaigns Increased Revenue

| Campaign | Incremental Revenue per Customer | Conversion Lift |
|---|---:|---:|
| Men's Email | +$0.7698 | +0.68 pp |
| Women's Email | +$0.4244 | +0.31 pp |

Both campaigns significantly increased revenue and conversion relative to Control. The results remained statistically significant after Holm correction across the four primary and secondary treatment comparisons.

### 2. Men's Email Showed the Strongest Overall Revenue Performance

Men's Email generated an estimated $0.3454 more revenue per customer than Women's Email.

A direct Welch's t-test found a nominally significant difference (p = 0.0305; 95% CI: [$0.0326, $0.6583]).

However, this comparison was conducted as a post-hoc exploratory analysis and was not included in the earlier multiple-testing correction. The result is promising but warrants further validation.

### 3. Purchase-History-Based Targeting Was Not Statistically Established

Customers were segmented into three groups based on previous merchandise purchases: Mens Only, Womens Only, and Both.

Men's Email showed particularly strong observed revenue lift among customers who had purchased from both merchandise categories (+$1.8250 per customer).

However, a joint interaction test using HC3 robust standard errors did not find statistically significant treatment effect heterogeneity (Wald chi-square = 6.8901, df = 4, p = 0.1418).

Therefore, the current evidence is insufficient to conclude that selecting different campaigns by purchase-history group would improve performance.


## Business Recommendations

**1. Prioritize Men's Email as the leading campaign candidate.**

Men's Email generated the highest estimated incremental revenue per customer. It is the strongest candidate for broader use when campaign costs and contribution margins are comparable.

However, the direct comparison with Women's Email was exploratory, so further validation is recommended before establishing a long-term campaign strategy.

**2. Avoid premature purchase-history-based targeting.**

Although treatment effects varied descriptively across purchase-history groups, the interaction test did not establish statistically significant heterogeneity.

There is currently insufficient evidence that assigning different emails based on previous merchandise purchases would outperform a common campaign strategy.

**3. Incorporate profitability into future experiments.**

Future evaluations should consider campaign costs, contribution margins, and longer-term customer outcomes alongside incremental revenue.

## Methodology

The analysis combines SQL-based data exploration with statistical inference in Python.

- **Data Validation:** Checked missing values, invalid records, and consistency across experimental groups.
- **Experiment Validation:** Evaluated sample ratio mismatch (SRM) using a chi-square test and examined baseline covariate balance using standardized mean differences.
- **Treatment Effect Estimation:** Calculated incremental revenue per customer and conversion rate differences relative to Control.
- **Statistical Inference:** Applied Welch's t-tests, two-proportion z-tests, and 95% confidence intervals.
- **Robustness Checks:** Used bootstrap confidence intervals and Holm correction across four treatment-versus-control hypothesis tests.
- **Subgroup Analysis:** Examined purchase-history segments using OLS interaction terms, HC3 robust standard errors, and a joint Wald test.

**Tools:** PostgreSQL, SQL, Python, pandas, NumPy, SciPy, statsmodels, Matplotlib, and Jupyter Notebook.

## Project Structure

```text
ab-testing-customer-targeting/
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_data_validation.sql
│   ├── 03_experiment_validation.sql
│   ├── 04_experiment_outcomes.sql
│   └── 05_subgroup_analysis.sql
├── notebooks/
│   ├── 01_experiment_validation.ipynb
│   ├── 02_treatment_effect_analysis.ipynb
│   └── 03_subgroup_analysis.ipynb
├── .gitignore
└── README.md
```

The raw dataset is excluded from version control. To reproduce the analysis, download the CSV and save it locally as `data/raw/hillstrom.csv`.

### Analysis Notebooks

1. [Experiment Validation](notebooks/01_experiment_validation.ipynb) — Randomization checks, sample ratio mismatch, and baseline balance.
2. [Treatment Effect Analysis](notebooks/02_treatment_effect_analysis.ipynb) — Revenue and conversion effects, confidence intervals, and robustness checks.
3. [Subgroup Analysis](notebooks/03_subgroup_analysis.ipynb) — Purchase-history-based treatment effects, interaction testing, and targeting recommendations.

## How to Reproduce

1. Download the Hillstrom dataset from the source linked above (or the public CSV copy). Create a local `data/raw/` directory and save the file as `hillstrom.csv`.
2. Create a PostgreSQL database named `hillstrom_ab_test`.
3. Execute `sql/01_create_table.sql` to create the experiment table.
4. Import the CSV into the `hillstrom` table using pgAdmin or another PostgreSQL import method.
5. Execute the remaining SQL scripts in numerical order.
6. Install the required Python libraries and open the notebooks in Jupyter or VS Code.
7. Run the notebooks in numerical order, using the `notebooks/` directory as the working directory.

The SQL scripts provide the detailed data validation and aggregation logic, while the notebooks document statistical inference, uncertainty estimates, and interpretation.

## Limitations

- The direct campaign comparison and subgroup analyses were exploratory rather than prespecified.
- Subgroup estimates, particularly for customers who previously purchased both merchandise categories, have substantial uncertainty.
- Subgroup confidence intervals were not adjusted for multiple comparisons.
- Campaign costs and contribution margins were unavailable, preventing a complete profitability assessment.
- The dataset lacks detailed purchase timing and long-term customer outcomes.

## Conclusion

Both email campaigns increased revenue per customer in the randomized experiment, with Men's Email emerging as the strongest overall candidate.

However, the results did not establish that purchase-history-based personalization would improve campaign performance. Future experiments should validate campaign selection and targeting strategies using prespecified hypotheses and profitability metrics.
