/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - SQL example for Combining multiple time-variant objects.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

-- Creation of a zero key for the date range
SELECT Hub.<Key>, CONVERT(DATETIME2(7), '1900-01-01') AS FROM_TIMESTAMP FROM <Hub> Hub
UNION
SELECT Sat1.<Key>, Sat1.<From Timestamp> AS FROM_TIMESTAMP FROM <Satellite 1> Sat1
UNION
SELECT Sat2.<Key>, Sat2.<From Timestamp> AS FROM_TIMESTAMP FROM <Satellite 2> Sat2


-- Creation of time periods
SELECT
  <Key>,
  FROM_TIMESTAMP,
  LEAD(FROM_TIMESTAMP,1,'9999-12-31') OVER (PARTITION BY <Key> ORDER BY FROM_TIMESTAMP ASC) AS BEFORE_TIMESTAMP
FROM
(
  <results from step 1>
) Timestamps


SELECT
  Hub.<Key>,
  -- Data Item Mappings for the Hub
  Hub.<Business Key>,
  -- Data Item Mappings for Satellite 1
  Sat1.<Column 1>,
  Sat1.<Column 2>,
  Sat1.<Column 3>,
  -- Data Item Mappings for Satellite 2
  Sat2.<Column 1>,
  Sat2.<Column 2>,
  FROM_TIMESTAMP
FROM
(
  <results from step 2>
) TimePeriods
-- Joining the Hub, for the business key
INNER JOIN <Hub> Hub
   ON TimePeriods.<Key> =  Hub.<Key>
-- Joining the context for Satellite 1
LEFT OUTER JOIN <Satellite 1> Sat1
   ON TimePeriods.CUSTOMER_SK = Sat1.[CUSTOMER_SK]
  AND Sat1.<From Timestamp> <= TimePeriods.FROM_TIMESTAMP
  AND Sat1.<Before Timestamp> > TimePeriods.BEFORE_TIMESTAMP
-- Joining the context for Satellite 2
LEFT OUTER JOIN <Satellite 2> Sat1
   ON TimePeriods.CUSTOMER_SK = Sat2.[CUSTOMER_SK]
  AND Sat2.<From Timestamp> <= TimePeriods.FROM_TIMESTAMP
  AND Sat2.<Before Timestamp> > TimePeriods.BEFORE_TIMESTAMP
