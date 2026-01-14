/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Design Pattern — Dimensional Modeling - Loading a Dimension from the Persistent Staging Area.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- Select all variations of the available time intervals
WITH TimeIntervals AS (
  SELECT INSERT_DATETIME FROM PSA_Table1
  UNION
  SELECT INSERT_DATETIME FROM PSA_Table2
),

-- Calculate the ranges (time intervals / slices) between available time intervals
Ranges AS (
  SELECT
    INSERT_DATETIME AS EFFECTIVE_DATETIME,
    (
      SELECT ISNULL(MIN(INSERT_DATETIME), '99991231')
      FROM TimeIntervals
      WHERE INSERT_DATETIME > TimeIntervals1.INSERT_DATETIME
    ) AS EXPIRY_DATETIME
  FROM TimeIntervals AS TimeIntervals1
),

-- Connect source table 1
Table1 AS (
  SELECT
    c.PSA_Table1_SK,
    c.Fundcode,
    c.Total_Amount,
    c.INSERT_DATETIME AS EFFECTIVE_DATETIME,
    COALESCE(MIN(c2.INSERT_DATETIME), CONVERT(DATETIME, '99991231')) AS EXPIRY_DATETIME
  FROM PSA_Table1 c
  LEFT JOIN PSA_Table1 c2 ON
    c.Fundcode = c2.Fundcode AND
    c.INSERT_DATETIME < c2.INSERT_DATETIME
  GROUP BY c.PSA_Table1_SK, c.Fundcode, c.Total_Amount, c.INSERT_DATETIME
),

-- Connect source table 2
Table2 AS (
  SELECT
    c.PSA_Table2_SK,
    c.Fundcode,
    c.Short_name,
    c.Additional_amount,
    c.INSERT_DATETIME AS EFFECTIVE_DATETIME,
    COALESCE(MIN(c2.INSERT_DATETIME), CONVERT(DATETIME, '99991231')) AS EXPIRY_DATETIME
  FROM PSA_Table2 c
  LEFT JOIN PSA_Table2 c2 ON
    c.Fundcode = c2.Fundcode AND
    c.INSERT_DATETIME < c2.INSERT_DATETIME
  GROUP BY c.PSA_Table2_SK, c.Fundcode, c.Short_Name, c.Additional_Amount, c.INSERT_DATETIME
)

-- Join tables to time ranges
SELECT
  Table1.Fundcode,
  Table1.Total_Amount,
  Table2.Short_Name,
  Table2.Additional_Amount,
  R.EFFECTIVE_DATETIME,
  R.EXPIRY_DATETIME
FROM Ranges R
LEFT JOIN Table1 ON NOT (Table1.EFFECTIVE_DATETIME >= R.EXPIRY_DATETIME OR Table1.EXPIRY_DATETIME <= R.EFFECTIVE_DATETIME)
LEFT JOIN Table2 ON NOT (Table2.EFFECTIVE_DATETIME >= R.EXPIRY_DATETIME OR Table2.EXPIRY_DATETIME <= R.EFFECTIVE_DATETIME)