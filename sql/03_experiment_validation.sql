-- 1. Sample Ratio Mismatch (SRM)
-- Assumed allocation ratio: 1:1:1

WITH group_counts AS (
    SELECT
        segment,
        COUNT(*) AS observed_count
    FROM hillstrom
    GROUP BY segment
),
group_expected AS (
    SELECT
        segment,
        observed_count,
        SUM(observed_count) OVER () / 3.0 AS expected_count
    FROM group_counts
)
SELECT
    segment,
    observed_count,
    ROUND(expected_count, 2) AS expected_count,
    ROUND(
        POWER(observed_count - expected_count, 2)
        / expected_count,
        6
    ) AS chi_square_component
FROM group_expected
ORDER BY segment;


-- 2. Covariate balance across experiment groups

SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(history), 2) AS avg_history,
    ROUND(100.0 * AVG(newbie), 2) AS newbie_pct,
    ROUND(100.0 * AVG(mens), 2) AS mens_pct,
    ROUND(100.0 * AVG(womens), 2) AS womens_pct
FROM hillstrom
GROUP BY segment
ORDER BY segment;


-- 3. Standard deviations of pre-treatment covariates

SELECT 
    segment,
    ROUND(AVG(history), 2) AS avg_history,
    ROUND(STDDEV_SAMP(history), 2) AS sd_history,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(STDDEV_SAMP(recency), 2) AS sd_recency
FROM hillstrom
GROUP BY segment
ORDER BY segment;


-- 4. Standardized Mean Differences (SMD)
-- Compare each treatment group against the control group.

WITH group_stats AS (
    SELECT
        segment,
        AVG(history) AS avg_history,
        STDDEV_SAMP(history) AS sd_history,
        AVG(recency) AS avg_recency,
        STDDEV_SAMP(recency) AS sd_recency
    FROM hillstrom
    GROUP BY segment
)
SELECT
    t.segment AS treatment_group,

    ROUND(
        (t.avg_history - c.avg_history) /
        SQRT(
            (POWER(t.sd_history, 2) +
            POWER(c.sd_history, 2)) / 2
        ),
        4
    ) AS smd_history,

    ROUND(
        (t.avg_recency - c.avg_recency) /
        SQRT(
            (POWER(t.sd_recency, 2) +
            POWER(c.sd_recency, 2)) / 2
        ),
        4
    ) AS smd_recency

FROM group_stats t
CROSS JOIN group_stats c
WHERE c.segment = 'No E-Mail'
    AND t.segment <> 'No E-Mail'
ORDER BY t.segment;

-- SMD Results:
-- Mens E-Mail:   history = 0.0076, recency = 0.0068
-- Womens E-Mail: history = 0.0065, recency = 0.0052
--
-- Interpretation:
-- Both treatment groups show very small standardized
-- mean differences relative to the control group.


-- 5. SMD for binary pre-treatment covariates

WITH group_stats AS (
    SELECT
        segment, 
        AVG(newbie) AS avg_newbie,
        STDDEV_SAMP(newbie) AS sd_newbie,
        AVG(mens) AS avg_mens,
        STDDEV_SAMP(mens) AS sd_mens,
        AVG(womens) AS avg_womens,
        STDDEV_SAMP(womens) AS sd_womens
    FROM hillstrom
    GROUP BY segment
)
SELECT
    t.segment AS treatment_group,

    ROUND(
        (t.avg_newbie - c.avg_newbie) /
        SQRT((POWER(t.sd_newbie, 2) +
            POWER(c.sd_newbie, 2)) / 2),
        4
    ) AS smd_newbie,

    ROUND(
        (t.avg_mens - c.avg_mens) /
        SQRT((POWER(t.sd_mens, 2) +
            POWER(c.sd_mens, 2)) / 2),
        4
    ) AS smd_mens,

    ROUND(
        (t.avg_womens - c.avg_womens) /
        SQRT((POWER(t.sd_womens, 2) +
            POWER(c.sd_womens, 2)) / 2),
        4
    ) AS smd_womens

FROM group_stats t
CROSS JOIN group_stats c
WHERE c.segment = 'No E-Mail'
    AND t.segment <> 'No E-Mail'
ORDER BY t.segment;