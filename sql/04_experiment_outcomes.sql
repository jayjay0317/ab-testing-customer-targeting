-- 1. Overall experiment performance by group

SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(spend), 4) AS avg_spend_per_customer,
    ROUND(100.0 * AVG(conversion), 2) AS conversion_rate_pct,
    ROUND(100.0 * AVG(visit), 2) AS visit_rate_pct,
    ROUND(SUM(spend), 2) AS total_revenue
FROM hillstrom
GROUP BY segment
ORDER BY segment;


-- 2. Treatment effects relative to the control group

WITH group_metrics AS (
    SELECT
        segment,
        AVG(spend) AS avg_spend,
        AVG(conversion) AS conversion_rate,
        AVG(visit) AS visit_rate
    FROM hillstrom
    GROUP BY segment
)

SELECT
    t.segment AS treatment_group,

    ROUND(
        t.avg_spend - c.avg_spend,
        4
    ) AS incremental_spend_per_customer,

    ROUND(
        100.0 * (t.avg_spend / NULLIF(c.avg_spend, 0) -1),
        2
    ) AS revenue_lift_pct,

    ROUND(
        100.0 * (t.conversion_rate - c.conversion_rate),
        2
    ) AS conversion_lift_pp,

    ROUND(
        100.0 * (t.visit_rate - c.visit_rate),
        2
    ) AS visit_lift_pp

FROM group_metrics t
CROSS JOIN group_metrics c
WHERE c.segment = 'No E-Mail'
    AND t.segment <> 'No E-Mail'
ORDER BY t.segment;


-- 3. Summary statistics for statistical inference

SELECT
    segment,
    COUNT(*) AS sample_size,
    SUM(conversion) AS conversions,
    SUM(visit) AS visits,
    ROUND(AVG(spend), 4) AS avg_spend,
    ROUND(STDDEV_SAMP(spend), 4) AS sd_spend 
FROM hillstrom
GROUP BY segment
ORDER BY segment;