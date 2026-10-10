-- 1. Experiment group distribution

SELECT
	segment, 
	COUNT(*) AS customer_count,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
		2
	) AS percentage
FROM hillstrom
GROUP BY segment
ORDER BY segment;

-- Results:
-- Mens E-Mail:   21,307 (33.29%)
-- No E-Mail:     21,306 (33.29%)
-- Womens E-Mail: 21,387 (33.42%)
-- Total:         64,000 (100.00%)
--
-- Observation:
-- Group sizes are close to an equal 1:1:1 allocation.
-- A chi-square goodness-of-fit test will be used to check for SRM.


-- 2. Check missing values

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(recency) AS null_recency,
    COUNT(*) - COUNT(history_segment) AS null_history_segment,
    COUNT(*) - COUNT(history) AS null_history,
    COUNT(*) - COUNT(mens) AS null_mens,
    COUNT(*) - COUNT(womens) AS null_womens,
    COUNT(*) - COUNT(zip_code) AS null_zipcode,
    COUNT(*) - COUNT(newbie) AS null_newbie,
    COUNT(*) - COUNT(channel) AS null_channel,
    COUNT(*) - COUNT(segment) AS null_segment,
    COUNT(*) - COUNT(visit) AS null_visit,
    COUNT(*) - COUNT(conversion) AS null_conversion,
    COUNT(*) - COUNT(spend) AS null_spend
FROM hillstrom;

-- Results:
-- Total rows: 64,000
-- No missing values were found in any of the 12 columns.


-- 3. Check invalid values

SELECT
    COUNT(*) FILTER (WHERE visit NOT IN (0, 1)) AS invalid_visit,
    COUNT(*) FILTER (WHERE conversion NOT IN (0, 1)) AS invalid_conversion,
    COUNT(*) FILTER (WHERE newbie NOT IN (0, 1)) AS invalid_newbie,
    COUNT(*) FILTER (WHERE mens NOT IN (0, 1)) AS invalid_mens,
    COUNT(*) FILTER (WHERE womens NOT IN (0, 1)) AS invalid_womens,
    COUNT(*) FILTER (WHERE spend < 0) AS negative_spend,
    COUNT(*) FILTER (WHERE history < 0) AS negative_history,
    COUNT(*) FILTER (WHERE recency < 0) AS negative_recency,
    COUNT(*) FILTER (
        WHERE segment NOT IN (
            'No E-Mail',
            'Mens E-Mail',
            'Womens E-Mail'
        )
    ) AS invalid_segment
FROM hillstrom;

-- Results:
-- No invalid binary values, negative amounts,
-- or unexpected experiment groups were found.


-- 4. Inspect categorical variable values

SELECT
    'history_segment' AS column_name,
    history_segment AS category,
    COUNT(*) AS customer_count
FROM hillstrom
GROUP BY history_segment

UNION ALL

SELECT
    'zip_code',
    zip_code,
    COUNT(*)
FROM hillstrom
GROUP BY zip_code

UNION ALL

SELECT
    'channel',
    channel,
    COUNT(*)
FROM hillstrom
GROUP BY channel

ORDER BY column_name, category

-- Results:
-- channel: 3 categories (Web, Phone, Multichannel)
-- history_segment: 7 spending categories
-- zip_code: 3 categories (Rural, Surburban, Urban)
-- Each variable accounts for all 64,000 customers.
--
-- Note:
-- "Surburban" is a misspelling of "Suburban" in the source data.
-- Standardize the label when preparing data for analysis.


-- 5. Check consistency between conversion and spending

SELECT
    COUNT(*) FILTER (
        WHERE conversion = 0 AND spend > 0
    ) AS spend_without_conversion,

    COUNT(*) FILTER (
        WHERE conversion = 1 AND spend = 0
    ) AS conversion_without_spend
FROM hillstrom;

-- Results:
-- spend_without_conversion: 0
-- conversion_without_spend: 0
--
-- Observation:
-- No inconsistencies were found between conversion and spend
-- under the validation rules tested.