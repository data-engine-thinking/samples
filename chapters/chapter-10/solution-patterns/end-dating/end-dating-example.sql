/*******************************************************************************
 * Data Engine Thinking
 *******************************************************************************
 *
 * Purpose:
 *   - End-dating example for time-variant records.
 *
 * Disclaimer:
 *   - See disclaimer.md in the repository root.
 *
 ******************************************************************************/

UPDATE Main
SET 
  [Before_Timestamp] = COALESCE([Lead_From_Timestamp],'9999-12-31')
FROM <Table> Main
JOIN 
( 
  -- Select the next timestamp for the leftover records
  SELECT 
    <Key>,
    LEAD([From_Timestamp]) OVER (
      PARTITION BY <Key>, 
      ORDER BY [From_Timestamp] ASC
    ) AS [Lead_From_Timestamp],
    ROW_NUMBER() OVER (
      PARTITION BY <Key>,
      ORDER BY [From_Timestamp] DESC
    ) AS RN,
    [From_Timestamp]
  FROM <Table>
  JOIN 
  (
    -- Only retrieve all open records
    SELECT
      <Key> AS Sub_<Key>,
      [Before_Timestamp] AS [Sub_Before_Timestamp]
    FROM <table>
    WHERE [Before_Timestamp] = '9999-12-31'
    GROUP BY <Key>, [Before_Timestamp]
    HAVING COUNT(*) > 1
  ) Sub 
    ON <Key> = Sub_<Key>
    AND [Before_Timestamp] = [Sub_Before_Timestamp]
) Final 
    ON <Key> = Sub_<Key> 
    AND Main.[From_Timestamp] = Final.[From_Timestamp]
WHERE RN! = 1


