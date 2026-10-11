-- 1. Experiment outcomes by men's merchandise purchase history

SELECT
    mens AS purchased_mens_merchandise,
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(spend), 4) AS avg_spend_per_customer,
    ROUND(100.0 * AVG(conversion), 2) AS conversion_rate_pct
FROM hillstrom
GROUP BY mens, segment
ORDER BY mens, segment;


-- 2. Customer segments by merchandise purchase history

SELECT
    mens,
    womens,
    COUNT(*) AS customer_count
FROM hillstrom
GROUP BY mens, womens
ORDER BY mens, womens;

-- Results:
-- Women's merchandise only: 28,734 customers
-- Men's merchandise only: 28,818 customers
-- Both categories: 6,448 customers
-- Neither category: 0 customers
--
-- The three observed purchase-history groups are mutually exclusive.
-- Merchandise purchase history does not identify customer gender.


-- 3. Experiment outcomes by mutually exclusive purchase-history groups

WITH customer_groups AS (
    SELECT
        CASE
            WHEN mens = 1 AND womens = 0 THEN 'Mens Only'
            WHEN mens = 0 AND womens = 1 THEN 'Womens Only'
            WHEN mens = 1 AND womens = 1 THEN 'Both'
            ELSE 'Neither'
        END AS history_group,
        segment,
        spend,
        conversion
    FROM hillstrom
)
SELECT
    history_group,
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(spend), 4) AS avg_spend_per_customer,
    ROUND(100.0 * AVG(conversion), 2) AS conversion_rate_pct
FROM customer_groups
GROUP BY history_group, segment
ORDER BY history_group, segment;


-- 4. Treatment effects within purchase-history groups

SELECT
    CASE 
        WHEN mens = 1 AND womens = 0 THEN 'Mens Only'
        WHEN mens = 0 AND womens = 1 THEN 'Womens Only'
        WHEN mens = 1 AND womens = 1 THEN 'Both'
        ELSE 'Neither'
    END AS history_group,

    ROUND(
        AVG(spend) FILTER (WHERE segment = 'Mens E-Mail')
        - AVG(spend) FILTER (WHERE segment = 'No E-Mail'),
        4
    ) AS mens_email_revenue_effect,

    ROUND(
        AVG(spend) FILTER (WHERE segment = 'Womens E-Mail')
        - AVG(spend) FILTER (WHERE segment = 'No E-Mail'),
        4
    ) AS womens_email_revenue_effect,

    ROUND(
        100.0 * (
            AVG(conversion) FILTER (WHERE segment = 'Mens E-Mail')
            - AVG(conversion) FILTER (WHERE segment = 'No E-Mail')
        ),
        2
    ) AS mens_email_conversion_lift_pp,

    ROUND(
        100.0 * (
            AVG(conversion) FILTER (WHERE segment = 'Womens E-Mail')
            - AVG(conversion) FILTER (WHERE segment = 'No E-Mail')
        ),
        2
    ) AS womens_email_conversion_lift_pp

FROM hillstrom
GROUP BY mens, womens
ORDER BY history_group;