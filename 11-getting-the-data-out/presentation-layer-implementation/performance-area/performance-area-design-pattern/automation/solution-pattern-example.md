# Performance area
## Solution pattern example

### Example timeline-based PIT
```sql
SELECT
  -- New timeline
  TimePeriods.FROM_TIMESTAMP,
  TimePeriods.BEFORE_TIMESTAMP,
  -- Hub surrogate key(s)
  Hub.[Customer_Surrogate_Key]  AS [Hub_Customer_Customer_Surrogate_Key],
  -- Pointer Satellite 1
  Sat1.[Customer_Surrogate_Key] AS [Sat_Customer_Details_Sales_Customer_Surrogate_Key],
  Sat1.[Inscription_Timestamp]  AS [Sat_Customer_Details_Sales_Inscription_Timestamp],
  Sat1.[Inscription_Record_Id]  AS [Sat_Customer_Details_Sales_Inscription_Record_Id],
  Sat1.[State_From_Timestamp]   AS [Sat_Customer_Details_Sales_From_Timestamp],
  -- Pointer Satellite 2
  Sat2.[Customer_Surrogate_Key] AS [Sat_Customer_Details_Contact_Customer_Surrogate_Key],
  Sat2.[Inscription_Timestamp]  AS [Sat_Customer_Details_Contact_Inscription_Timestamp],
  Sat2.[Inscription_Record_Id]  AS [Sat_Customer_Details_Contact_Inscription_Record_Id],
  Sat2.[State_From_Timestamp]   AS [Sat_Customer_Details_Contact_From_Timestamp],
  -- Optional columns
  Hub.[Customer_Code]
FROM
(
  -- Creation of time periods
  SELECT
    [Customer_Surrogate_Key],
    FROM_TIMESTAMP,
    LEAD(FROM_TIMESTAMP,1,'9999-12-31')
        OVER (PARTITION BY [Customer_Surrogate_Key]
        ORDER BY FROM_TIMESTAMP ASC)
      AS BEFORE_TIMESTAMP
  FROM
  (
    -- Creation of a zero key for the timeline
    SELECT
      Hub.[Customer_Surrogate_Key],
      CONVERT(DATETIME2(7), '1900-01-01') AS FROM_TIMESTAMP
    FROM [Hub_Customer] Hub
    UNION
    -- Combined set of all available from timestamp values
    SELECT Sat1.[Customer_Surrogate_Key], Sat1.[State_From_Timestamp] AS FROM_TIMESTAMP
    FROM [Sat_Customer_Details_Sales] Sat1
    UNION
    SELECT Sat2.[Customer_Surrogate_Key], Sat2.[State_From_Timestamp] AS FROM_TIMESTAMP
    FROM [Sat_Customer_Details_Contact] Sat2
   ) Timestamps
) TimePeriods
-- Joining the Hub
INNER JOIN [Hub_Customer] Hub
  ON TimePeriods.[Customer_Surrogate_Key] =  Hub.[Customer_Surrogate_Key]
-- Joining Satellite 1
LEFT JOIN [Sat_Customer_Details_Sales] Sat1
  ON TimePeriods.[Customer_Surrogate_Key] = Sat1.[Customer_Surrogate_Key]
  AND Sat1.[State_From_Timestamp] <= TimePeriods.FROM_TIMESTAMP
  AND Sat1.[State_Before_Timestamp] > TimePeriods.BEFORE_TIMESTAMP
-- Joining Satellite 2
LEFT JOIN [Sat_Customer_Details_Contact] Sat2
  ON TimePeriods.[Customer_Surrogate_Key] = Sat2.[Customer_Surrogate_Key]
  AND Sat2.[State_From_Timestamp] <= TimePeriods.FROM_TIMESTAMP
  AND Sat2.[State_Before_Timestamp] > TimePeriods.BEFORE_TIMESTAMP
```

### Example snapshot PIT
```sql
DECLARE @AssertionSnapshotTimestamp DATETIME2(7) = SYSUTCDATETIME();
DECLARE @StateSnapshotTimestamp DATETIME2(7) = CAST('2025-02-25' AS DATETIME2(7));

SELECT
  -- New snapshot timestamp
  @StateSnapshotTimestamp AS [Snapshot_Timestamp],
  -- Hub surrogate key(s)
  Hub.[Customer_Surrogate_Key]  AS [Hub_Customer_Customer_Surrogate_Key],
  -- Pointer Satellite 1
  Sat1.[Customer_Surrogate_Key] AS [Sat_Customer_Details_Sales_Customer_Surrogate_Key],
  Sat1.[Inscription_Timestamp]  AS [Sat_Customer_Details_Sales_Inscription_Timestamp],
  Sat1.[Inscription_Record_Id]  AS [Sat_Customer_Details_Sales_Inscription_Record_Id],
  Sat1.[State_From_Timestamp]   AS [Sat_Customer_Details_Sales_From_Timestamp],
  -- Pointer Satellite 2
  Sat2.[Customer_Surrogate_Key] AS [Sat_Customer_Details_Contact_Customer_Surrogate_Key],
  Sat2.[Inscription_Timestamp]  AS [Sat_Customer_Details_Contact_Inscription_Timestamp],
  Sat2.[Inscription_Record_Id]  AS [Sat_Customer_Details_Contact_Inscription_Record_Id],
  Sat2.[State_From_Timestamp]   AS [Sat_Customer_Details_Contact_From_Timestamp],
  -- Optional columns
  Hub.[Customer_Code]
FROM [Hub_Customer] Hub
LEFT JOIN [Sat_Customer_Details_Sales] sat1
ON
  -- Assertion timeline
  sat1.[Inscription_Timestamp] <= @AssertionSnapshotTimestamp
  -- State timeline
  AND sat1.[State_From_Timestamp]   <= @StateSnapshotTimestamp
  AND sat1.[State_Before_Timestamp] >  @StateSnapshotTimestamp
LEFT JOIN [Sat_Customer_Details_Contact] sat2
ON
  -- Assertion timeline
  sat2.[Inscription_Timestamp] <= @AssertionSnapshotTimestamp
  -- State timeline
  AND sat2.[State_From_Timestamp]   <= @StateSnapshotTimestamp
  AND sat2.[State_Before_Timestamp] >  @StateSnapshotTimestamp
```
